;rsi stack pointer to string
slen:
    push rdi
    mov rdi, rsi
    .loop
        cmp byte [rdi], 0
        jz .end
        inc rdi
        jmp .loop
    .end
        sub rdi, rsi
        mov rax, rdi

        pop rdi
        ret

;rsi: stack pointer to string
sprint:
    push rdi
    push rdx
    
    call slen
    mov rdx, rax

    mov rax, 1
    mov rdi, 1

    syscall

    pop rdx
    pop rdi
    ret

sprintln:
    push rsi

    call sprint

    mov rsi, 0ah
    push rsi
    mov rsi, rsp
    call sprint
    pop rsi

    pop rsi
    ret