
traverseList:
    push rdi
    push rsi
    push rsp

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

        pop rsp
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