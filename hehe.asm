%include "stringfns.asm"
%include "linkedList.asm"

section .data

section .bss
    head resq 1
         resq 1
section .text

    extern _start


    _start:
        mov rdi, 9
        call initList

        mov rdi, 6
        call addNode
        mov rsp, rax

        call traverseList
        mov rsi, rax
        add rsi, 8
        mov rsi, [rsi]
        call iprintln

        mov rax, 60
        mov rdi, 0
        syscall