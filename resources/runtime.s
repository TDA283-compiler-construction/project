[BITS 64]

extern _printf
extern _puts
extern _scanf

section .data

ifmt1   db      "%d",   0xA, 0x0
ifmt2   db      "%d",   0x0
ffmt1   db      "%.1f", 0xA, 0x0
ffmt2   db      "%lf",  0x0

section .text

global _printString
_printString:
        jmp     _puts

global _printInt
_printInt:
        mov     rsi, rdi
        lea     rdi, [rel ifmt1]
        jmp     _printf

global _printDouble
_printDouble:
        lea     rdi, [rel ffmt1]
        mov     al, 1
        jmp     _printf

global _readInt
_readInt:
        push    rax
        lea     rdi, [rel ifmt2]
        lea     rsi, [rsp + 4]
        xor     eax, eax
        call    _scanf
        mov     eax, [rsp + 4]
        pop     rcx
        ret

global _readDouble
_readDouble:
        push    rax
        lea     rdi, [rel ffmt2]
        mov     rsi, rsp
        xor     eax, eax
        call    _scanf
        movsd   xmm0, [rsp]
        pop     rax
        ret

