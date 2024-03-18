%include "stringfns.asm"

struc ListNode
    .val: resb 8
    .next: resb 8
endstruc

section .data
    head:
        istruc ListNode
            at ListNode.val, db 1
            at ListNode.next, dq 0h
        iend
section .bss

section .text

    extern _start

    traverseList:
        push rsi
        mov rdi, rsp

        mov rsi, head

        .loop:
            cmp rsi, 1000
            jl .end

            mov rsi, [rsi]

            jmp .loop
        .end:
            mov rax, rsp
            mov rsp, rdi
            pop rsi
            ret

    addNode:
        push rdi
        push rsi
        mov rdi, rsp

        push rsi
        mov rsi, 7
        push rsi

        ;call traverseList
        ;mov qword [rax], rsp

        mov rax, rsp
        mov rsp, rdi

        pop rsi
        pop rdi
        ret

    _start:
        mov rsi, 6
        call addNode
        mov rsp, rax

        mov [head + ListNode.next], rsp
        mov r9, rsp

        mov rsi, 7
        call addNode
        mov rsp, rax

        mov [r9], rsp

        call traverseList
        mov rsi, rax
        add rsi, 8
        mov rsi, [rsi]
        call iprintln

        mov rax, 60
        mov rdi, 0
        syscall