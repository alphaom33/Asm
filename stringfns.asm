;rsi stack pointer to string
slen:
    push rdi
    mov rdi, rsi
    .loop:
        cmp byte [rdi], 0
        jz .end
        inc rdi
        jmp .loop
    .end:
        sub rdi, rsi
        mov rax, rdi

        pop rdi
        ret

debug:
    push rax
    push rdi
    push rsi
    push rdx
    push rcx

    mov rax, 1
    mov rdi, 1
    mov rsi, 48
    push rsi
    mov rsi, rsp
    mov rdx, 1
    syscall
    pop rsi

    mov rsi, 0ah
    push rsi
    mov rsi, rsp
    syscall
    pop rsi

    pop rcx
    pop rdx
    pop rsi
    pop rdi
    pop rax

    ret


;rsi: stack pointer to string
sprint:
    push rdi
    push rdx
    push rcx
    
    call slen
    mov rdx, rax

    mov rax, 1
    mov rdi, 1

    syscall

    pop rcx
    pop rdx
    pop rdi
    ret

;rsi: stack pointer to string
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

iprint:
    push rdi
    push rdx
    push rcx
    push rsi

    mov rdi, 0
    mov rax, rsi

    .divloop:
        inc rdi
        mov rdx, 0
        mov rcx, 10
        idiv rcx
        add rdx, 48
        push rdx
        cmp rax, 0
        jnz .divloop
    .printloop:
        dec rdi
        mov rsi, rsp
        call sprint
        pop rsi
        cmp rdi, 0
        jnz .printloop
    
    pop rsi
    pop rcx
    pop rdx
    pop rdi
    ret

iprintln:
    push rsi

    call iprint

    mov rsi, 0ah
    push rsi
    mov rsi, rsp
    call sprint
    pop rsi

    pop rsi
    ret

atoi:
    push rdi
    push rcx
    push rdx


    mov rdi, 0
    mov rax, 0
    .loop:
        cmp byte [rdi + rsi], 0
        jz .end

        xor rcx, rcx
        mov cl, [rdi + rsi]

        cmp cl, 57
        jg .end
        cmp cl, 48
        jl .end

        sub cl, 48

        add rax, rcx
        mov rcx, 10
        mul rcx

        inc rdi
        jmp .loop
    .end:
        mov rdx, 0
        mov rcx, 10
        div rcx

        pop rdx
        pop rcx
        pop rdi

        ret