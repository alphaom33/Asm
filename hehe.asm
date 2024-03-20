%include "stringfns.asm"
%include "linkedList.asm"

section .data

section .bss
    head resq 1
         resq 1

    rand resb 1

section .text

    extern _start

    _start:
        mov rdi, 9
        call initList

        mov rsi, 0
        mov rcx, 0
        mov rdx, 0
        .loop:
            push rcx
            mov rdi, rand
            mov rsi, 1
            mov rax, 318
            syscall
            mov rsi, [rand]
            pop rcx

            mov rdi, [rand]
            call addNode
            mov rsp, rax

            inc rcx
            cmp rcx, 100
            je .end
            jmp .loop

        .end:
        
        call printList

        call exit

    exit:
        mov rax, 60
        mov rdi, 0
        syscall