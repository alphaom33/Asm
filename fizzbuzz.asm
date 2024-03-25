bits 64
default rel

%include 'stringfns.asm'

section .data
    fizz db "FIZZ", 0h
    buzz db "BUZZ", 0h

section .text
    global _start

_start:
    mov rdi, 0
    mov r8, 0

    .loop:
        cmp rdi, 100
        je .end
        inc rdi

        .fizz:
            push rdi
            mov rax, rdi
            mov rdi, 3
            call modulo
            pop rdi


            cmp rax, 0
            jne .buzz

            mov rsi, fizz
            call sprint

            mov r8, 1
        .buzz:
            push rdi
            mov rax, rdi
            mov rdi, 5
            call modulo
            pop rdi

            cmp rax, 0
            jne .num

            mov rsi, buzz
            call sprint

            mov r8, 1
        .num:
            cmp r8, 0
            jne .next

            mov rsi, rdi
            call iprint
        .next:
            mov rsi, 0ah
            push rsi
            mov rsi, rsp
            call sprint
            pop rsi

            mov r8, 0
            jmp .loop

    .end:
        call exit


modulo:
    push rdx
    mov rdx, 0
    div rdi
    mov rax, rdx
    pop rdx
    ret

exit:
    mov rax, 60
    mov rdi, 0
    syscall