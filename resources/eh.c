#include <unwind.h>
#include <stdio.h>
#include <stdlib.h>
#include <stddef.h>
#include <inttypes.h>
#include <string.h>
#include "object.h"

#define JAVALETTE_EXCEPTION_CLASS 1111

VTbl Exception = {0,NULL};
VTbl ArrayException = {0,&Exception};

typedef struct ExceptionObject ExceptionObject;
struct ExceptionObject {
    VTbl *vtbl;
    struct _Unwind_Exception ue;
};

typedef struct ArrayExceptionObject ArrayExceptionObject;
struct ArrayExceptionObject {
    ExceptionObject base;
    int64_t index;
};

__attribute__((noreturn)) void __jl_abort()
{
    printf("Program terminated due to unhandled exception\n");
    exit(1);
}

/* Pointer encodings, from dwarf2.h.  */
#define DW_EH_PE_absptr         0x00
#define DW_EH_PE_omit           0xff

#define DW_EH_PE_uleb128        0x01
#define DW_EH_PE_udata2         0x02
#define DW_EH_PE_udata4         0x03
#define DW_EH_PE_udata8         0x04
#define DW_EH_PE_sleb128        0x09
#define DW_EH_PE_sdata2         0x0A
#define DW_EH_PE_sdata4         0x0B
#define DW_EH_PE_sdata8         0x0C
#define DW_EH_PE_signed         0x08

#define DW_EH_PE_pcrel          0x10
#define DW_EH_PE_textrel        0x20
#define DW_EH_PE_datarel        0x30
#define DW_EH_PE_funcrel        0x40
#define DW_EH_PE_aligned        0x50

#define DW_EH_PE_indirect	0x80

#ifndef NO_SIZE_OF_ENCODED_VALUE

/* Given an encoding, return the number of bytes the format occupies.
   This is only defined for fixed-size encodings, and so does not
   include leb128.  */

static unsigned int
size_of_encoded_value (unsigned char encoding) __attribute__ ((unused));

__attribute__((noreturn)) void __jl_abort();

static unsigned int
size_of_encoded_value (unsigned char encoding)
{
    if (encoding == DW_EH_PE_omit)
        return 0;

    switch (encoding & 0x07) {
        case DW_EH_PE_absptr:
            return sizeof (void *);
        case DW_EH_PE_udata2:
            return 2;
        case DW_EH_PE_udata4:
            return 4;
        case DW_EH_PE_udata8:
            return 8;
    }
    __jl_abort();
}

#endif

#ifndef NO_BASE_OF_ENCODED_VALUE

/* Given an encoding and an _Unwind_Context, return the base to which
   the encoding is relative.  This base may then be passed to
   read_encoded_value_with_base for use when the _Unwind_Context is
   not available.  */

static _Unwind_Ptr
base_of_encoded_value (unsigned char encoding, struct _Unwind_Context *context)
{
    if (encoding == DW_EH_PE_omit)
        return 0;

    switch (encoding & 0x70) {
        case DW_EH_PE_absptr:
        case DW_EH_PE_pcrel:
        case DW_EH_PE_aligned:
            return 0;

        case DW_EH_PE_textrel:
            return _Unwind_GetTextRelBase (context);
        case DW_EH_PE_datarel:
            return _Unwind_GetDataRelBase (context);
        case DW_EH_PE_funcrel:
            return _Unwind_GetRegionStart (context);
    }
    __jl_abort();
}

#endif

/* Read an unsigned leb128 value from P, store the value in VAL, return
   P incremented past the value.  We assume that a word is large enough to
   hold any value so encoded; if it is smaller than a pointer on some target,
   pointers should not be leb128 encoded on that target.  */

static const unsigned char *
read_uleb128 (const unsigned char *p, _uleb128_t *val)
{
  unsigned int shift = 0;
  unsigned char byte;
  _uleb128_t result;

  result = 0;
  do
    {
      byte = *p++;
      result |= ((_uleb128_t)byte & 0x7f) << shift;
      shift += 7;
    }
  while (byte & 0x80);

  *val = result;
  return p;
}

/* Similar, but read a signed leb128 value.  */

static const unsigned char *
read_sleb128 (const unsigned char *p, _sleb128_t *val)
{
  unsigned int shift = 0;
  unsigned char byte;
  _uleb128_t result;

  result = 0;
  do
    {
      byte = *p++;
      result |= ((_uleb128_t)byte & 0x7f) << shift;
      shift += 7;
    }
  while (byte & 0x80);

  /* Sign-extend a negative value.  */
  if (shift < 8 * sizeof(result) && (byte & 0x40) != 0)
    result |= -(((_uleb128_t)1L) << shift);

  *val = (_sleb128_t) result;
  return p;
}

/* Load an encoded value from memory at P.  The value is returned in VAL;
   The function returns P incremented past the value.  BASE is as given
   by base_of_encoded_value for this encoding in the appropriate context.  */

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Waddress-of-packed-member"

static const unsigned char *
read_encoded_value_with_base (unsigned char encoding, _Unwind_Ptr base,
			      const unsigned char *p, _Unwind_Ptr *val)
{
  union unaligned
    {
      void *ptr;
      unsigned u2 __attribute__ ((mode (HI)));
      unsigned u4 __attribute__ ((mode (SI)));
      unsigned u8 __attribute__ ((mode (DI)));
      signed s2 __attribute__ ((mode (HI)));
      signed s4 __attribute__ ((mode (SI)));
      signed s8 __attribute__ ((mode (DI)));
    } __attribute__((__packed__));

  const union unaligned *u = (const union unaligned *) p;
  _Unwind_Internal_Ptr result;

  if (encoding == DW_EH_PE_aligned)
    {
      _Unwind_Internal_Ptr a = (_Unwind_Internal_Ptr) p;
      a = (a + sizeof (void *) - 1) & - sizeof(void *);
      result = *(_Unwind_Internal_Ptr *) a;
      p = (const unsigned char *) (_Unwind_Internal_Ptr) (a + sizeof (void *));
    }
  else
    {
      switch (encoding & 0x0f)
	{
	case DW_EH_PE_absptr:
	  result = (_Unwind_Internal_Ptr) u->ptr;
	  p += sizeof (void *);
	  break;

	case DW_EH_PE_uleb128:
	  {
	    _uleb128_t tmp;
	    p = read_uleb128 (p, &tmp);
	    result = (_Unwind_Internal_Ptr) tmp;
	  }
	  break;

	case DW_EH_PE_sleb128:
	  {
	    _sleb128_t tmp;
	    p = read_sleb128 (p, &tmp);
	    result = (_Unwind_Internal_Ptr) tmp;
	  }
	  break;

	case DW_EH_PE_udata2:
	  result = u->u2;
	  p += 2;
	  break;
	case DW_EH_PE_udata4:
	  result = u->u4;
	  p += 4;
	  break;
	case DW_EH_PE_udata8:
	  result = u->u8;
	  p += 8;
	  break;

	case DW_EH_PE_sdata2:
	  result = u->s2;
	  p += 2;
	  break;
	case DW_EH_PE_sdata4:
	  result = u->s4;
	  p += 4;
	  break;
	case DW_EH_PE_sdata8:
	  result = u->s8;
	  p += 8;
	  break;

	default:
	  __jl_abort();
	}

      if (result != 0)
	{
	  result += ((encoding & 0x70) == DW_EH_PE_pcrel
		     ? (_Unwind_Internal_Ptr) u : base);
	  if (encoding & DW_EH_PE_indirect)
	    result = *(_Unwind_Internal_Ptr *) result;
	}
    }

  *val = result;
  return p;
}

#pragma GCC diagnostic pop

#ifndef NO_BASE_OF_ENCODED_VALUE

/* Like read_encoded_value_with_base, but get the base from the context
   rather than providing it directly.  */

static inline const unsigned char *
read_encoded_value (struct _Unwind_Context *context, unsigned char encoding,
		    const unsigned char *p, _Unwind_Ptr *val)
{
  return read_encoded_value_with_base (encoding,
		base_of_encoded_value (encoding, context),
		p, val);
}

#endif

void __jl_throw(ExceptionObject *e) {
    e->ue.exception_class = JAVALETTE_EXCEPTION_CLASS;
    _Unwind_RaiseException(&e->ue);
    __jl_abort();
}

void __jl_throw_array_exception(int64_t index) {
    ArrayExceptionObject *e = malloc(sizeof(ArrayExceptionObject));
    memset(e, 0, sizeof(ArrayExceptionObject));
    e->base.vtbl = &ArrayException;
    e->index = index;
    __jl_throw(&e->base);
}

struct lsda_header_info
{
    _Unwind_Ptr Start;
    _Unwind_Ptr LPStart;
    _Unwind_Ptr ttype_base;
    const unsigned char *TType;
    const unsigned char *action_table;
    unsigned char ttype_encoding;
    unsigned char call_site_encoding;
};

static const unsigned char *
parse_lsda_header(struct _Unwind_Context *context, const unsigned char *p,
                  struct lsda_header_info *info)
{
    _uleb128_t tmp;
    unsigned char lpstart_encoding;

    info->Start = (context ? _Unwind_GetRegionStart(context) : 0);

    // Find @LPStart, the base to which landing pad offsets are relative.
    lpstart_encoding = *p++;
    if (lpstart_encoding != DW_EH_PE_omit)
        p = read_encoded_value(context, lpstart_encoding, p, &info->LPStart);
    else
        info->LPStart = info->Start;

    // Find @TType, the base of the handler and exception spec type data.
    info->ttype_encoding = *p++;
    if (info->ttype_encoding != DW_EH_PE_omit) {
#if _GLIBCXX_OVERRIDE_TTYPE_ENCODING
        /* Older ARM EABI toolchains set this value incorrectly, so use a
           hardcoded OS-specific format.  */
        info->ttype_encoding = _GLIBCXX_OVERRIDE_TTYPE_ENCODING;
#endif
        p = read_uleb128(p, &tmp);
        info->TType = p + tmp;
    }
    else
        info->TType = 0;

    // The encoding and length of the call-site table; the action table
    // immediately follows.
    info->call_site_encoding = *p++;
    p = read_uleb128 (p, &tmp);
    info->action_table = p + tmp;

    return p;
}

_Unwind_Reason_Code __jl_personality(int version,
		                             _Unwind_Action actions,
		                             _Unwind_Exception_Class exception_class,
		                              struct _Unwind_Exception *header,
                                      struct _Unwind_Context *context)
{
    if (exception_class != JAVALETTE_EXCEPTION_CLASS)
        return _URC_CONTINUE_UNWIND;

    const unsigned char *language_specific_data =
        (const unsigned char *)_Unwind_GetLanguageSpecificData(context);
    if (!language_specific_data)
        return _URC_CONTINUE_UNWIND;

    // Parse the LSDA header.
    struct lsda_header_info info;
    const unsigned char *p =
        parse_lsda_header (context, language_specific_data, &info);
    info.ttype_base = base_of_encoded_value(info.ttype_encoding, context);

    _Unwind_Ptr landing_pad = 0, ip;
    int ip_before_insn = 0;
    ip = _Unwind_GetIPInfo (context, &ip_before_insn);
    if (!ip_before_insn)
        --ip;
    const unsigned char *action_record;
    
    while (p < info.action_table)
    {
        _Unwind_Ptr cs_start, cs_len, cs_lp;
        _uleb128_t cs_action;

        // Note that all call-site encodings are "absolute" displacements.
        p = read_encoded_value(0, info.call_site_encoding, p, &cs_start);
        p = read_encoded_value(0, info.call_site_encoding, p, &cs_len);
        p = read_encoded_value(0, info.call_site_encoding, p, &cs_lp);
        p = read_uleb128(p, &cs_action);

        // The table is sorted, so if we've passed the ip, stop.
        if (ip < info.Start + cs_start)
            p = info.action_table;
        else if (ip < info.Start + cs_start + cs_len) {
            if (cs_lp)
                landing_pad = info.LPStart + cs_lp;
            if (cs_action)
                action_record = info.action_table + cs_action - 1;
            goto found_something;
        }
    }

    // If ip is not present in the table, call terminate.  This is for
    // a destructor inside a cleanup, or a library routine the compiler
    // was not expecting to throw.
    //found_type = found_terminate;
    goto do_something;

found_something:;
    int saw_cleanup = 0;
    if (landing_pad == 0) {
        // If ip is present, and has a null landing pad, there are
        // no cleanups or handlers to be run.
    } else if (action_record == 0) {
        // If ip is present, has a non-null landing pad, and a null
        // action table offset, then there are only cleanups present.
        // Cleanups use a zero switch value, as set above.
        saw_cleanup = 1;
    } else {
        size_t index = 0;
        for (;;)
        {
            _sleb128_t ar_filter, ar_disp;

            p = action_record;
            p = read_sleb128(p, &ar_filter);
            read_sleb128(p, &ar_disp);

            if (ar_filter == 0) {
                // Zero filter values are cleanups.
                saw_cleanup = 1;
            } else {
                // Positive filter values are handlers.
                _Unwind_Ptr ptr;

                ar_filter *= size_of_encoded_value(info.ttype_encoding);
                read_encoded_value_with_base(info.ttype_encoding, info.ttype_base,
                                                info.TType - ar_filter, &ptr);

                ExceptionObject *exception = (ExceptionObject *) ((uint8_t *) header - offsetof(ExceptionObject,ue));
                VTbl *vtbl = exception->vtbl;
                while (vtbl != NULL) {
                    if (vtbl == (void*) ptr) {
                        if ((actions & _UA_CLEANUP_PHASE) && (actions & _UA_HANDLER_FRAME)) {
                            _Unwind_SetIP(context, landing_pad);
                            _Unwind_SetGR(context, __builtin_eh_return_data_regno(0), (_Unwind_Word) header);
                            _Unwind_SetGR(context, __builtin_eh_return_data_regno(1), index+1);
                            return _URC_INSTALL_CONTEXT;
                        }

                        _Unwind_SetIP(context, landing_pad);
                        _Unwind_SetGR(context, __builtin_eh_return_data_regno(0), (_Unwind_Word) header);
                        _Unwind_SetGR(context, __builtin_eh_return_data_regno(1), index+1);
                        return _URC_HANDLER_FOUND;
                    }
                    vtbl = vtbl->base;
                }
            }

            if (ar_disp == 0)
                break;
            action_record = p + ar_disp;
            index++;
        }
    }

    if (saw_cleanup && (actions & _UA_CLEANUP_PHASE)) {
        _Unwind_SetIP(context, landing_pad);
        _Unwind_SetGR(context, __builtin_eh_return_data_regno(0), (_Unwind_Word) header);
        _Unwind_SetGR(context, __builtin_eh_return_data_regno(1), 0);
        return _URC_INSTALL_CONTEXT;
    }

do_something:
    return _URC_CONTINUE_UNWIND;
}
