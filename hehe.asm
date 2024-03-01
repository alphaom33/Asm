bits 64
default rel

%include 'prints.asm'

.data
    msg db "Hello, World!", 0h

.text
    global _start

_start:
    mov rsi, msg
    call sprintln


    mov rax, 60
    mov rdi, 0
    syscall