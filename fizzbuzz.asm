bits 64
default rel

%include 'stringfns.asm'

section .data
    fizz db "FIZZ"
    buzz db "BUZZ"

section .text
    global _start

_start:
    mov rdi, 0

    .loop:
        inc rdi
        mov r8, rsp

        .checkFizz:
            mov rdx, 0
            mov rsi, 3

            mov rax, rdi
            div rsi
            
            mov rcx, rdx
            cmp rcx, 0
            jne .checkBuzz

            mov r9, rsp
            push fizz
            mov rsi, 0h
            push rsi
            mov rsi, rsp
            call println

        .checkBuzz:
            mov rdx, 0
            mov rsi, 5

            mov rax, rdi
            div rsi
            
            mov rcx, rdx
            cmp rcx, 0
            jne .checkNum

            mov rsi, buzz
            push rsi        

        .checkNum:
            inc r8
            cmp byte [r8], 0h
            je .terminate

            mov rsi, rdi
            call iprint
            jmp .next
        .terminate:
            mov rsi, 0h
            push rsi
            mov rsi, r8
            call sprint

        .next:
            mov rsi, 0ah
            push rsi
            mov rsi, rsp
            call sprint
            pop rsi

            cmp rdi, 100
            jne .loop
    call exit

exit:
    mov rax, 60
    mov rdi, 0
    syscall