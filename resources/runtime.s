[BITS 64]

%ifidn __OUTPUT_FORMAT__, macho64
  %define label(X) _ %+ X
%elifidn __OUTPUT_FORMAT__, elf64
  %define label(X) X
%else
  %error "Format needs to be macho64 or elf64."
%endif

%define call_(X) call label(X)
%define jmp_(X)  jmp  label(X)

extern label(printf)
extern label(puts)
extern label(scanf)

section .data

ifmt1   db      "%d",   0xA, 0x0
ifmt2   db      "%d",   0x0
ffmt1   db      "%.1f", 0xA, 0x0
ffmt2   db      "%lf",  0x0

section .text

global label(printString)
label(printString):
        jmp_    (puts)

global label(printInt)
label(printInt):
        mov     rsi, rdi
        lea     rdi, [rel ifmt1]
        jmp_    (printf)

global label(printDouble)
label(printDouble):
        lea     rdi, [rel ffmt1]
        mov     al, 1
        jmp_    (printf)

global label(readInt)
label(readInt):
        push    rax
        lea     rdi, [rel ifmt2]
        lea     rsi, [rsp + 4]
        xor     eax, eax
        call_   (scanf)
        mov     eax, [rsp + 4]
        pop     rcx
        ret

global label(readDouble)
label(readDouble):
        push    rax
        lea     rdi, [rel ffmt2]
        mov     rsi, rsp
        xor     eax, eax
        call_   (scanf)
        movsd   xmm0, [rsp]
        pop     rax
        ret

