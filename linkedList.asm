
traverseList:
    push rdi
    push rsi

    mov rdi, head

    .loop:
        mov rsi, rdi
        mov rsi, [rsi]
        cmp rsi, 1000
        jle .end

        mov rdi, [rdi]

        jmp .loop
    .end:
        mov rax, rdi

        pop rsi
        pop rdi    
        ret

addNode:
    mov rsi, rsp

    push rdi
    mov rdi, 0h
    push rdi
    call traverseList
    mov qword [rax], rsp

    mov rax, rsp
    mov rsp, rsi
    ret

initList:
    push rsi

    mov rsi, head
    mov qword [rsi], 0h
    add rsi, 8
    mov qword [rsi], rdi
        
    pop rsi
    ret

getNode:
    push rsi
    push rdx
    push r8

    mov rsi, head

    .loop:
        mov r8, [rsi]
        cmp r8, 1000
        jle .success

        cmp rdx, rdi
        je .success
        inc rdx

        mov rsi, [rsi]

        jmp .loop
    .success:
        mov rax, rsi
        jmp .end
    .err:
        mov rax, -1
        jmp .end

    .end:
        pop r8
        pop rdx
        pop rsi

        ret

lLen:
    push rsi
    push rdi

    mov rdi, head

    .loop:
        mov rsi, [rdi]
        cmp rsi, 1000
        jle .end

        mov rdi, [rdi]

        jmp .loop
    .end:
        mov rax, rdi

        pop rdi
        pop rsi

        ret

printList:
    push rsi
    push rdi

    mov rdi, head
    .loop:
        mov rsi, [rdi]
        cmp rsi, 1000
        jle .end

        push rsi
        add rsi, 8
        mov rsi, [rsi]
        call iprintln
        pop rsi

        mov rdi, [rdi]

        jmp .loop
    .end:
        pop rdi
        pop rsi
        ret