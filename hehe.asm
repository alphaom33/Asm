bits 64
default rel

%include "stringfns.asm"
%include "linkedList.asm"

section .data

section .bss
    head resq 1
         resq 1

    rand resb 1

    current_stack resq 1

section .text

    extern _start
    extern malloc
    extern free

    _start:
         


        call exit

    exit:
        mov rax, 60
        mov rdi, 0
        syscall