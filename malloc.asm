%include "stringfns.asm"

%define NULL 0
%define SYSCALL_BRK 12

struc block_meta
   .next resq 1               ;pointer to the next block of "block_mata" struct
   .size resq 1               ;how many bytes can this block hold
   .free resb 1               ;is this block free (0 == no its not free) (1 == yes its is free)
endstruc
META_SIZE equ 17              ;the size of block_meta in bytes

section .data
   global_base dq NULL        ;pointer to the first "block_meta" struct
   current_sbrk dq 0

section .text
global _start
global _malloc

_start:
    push 400
    call _malloc                       ;allocationg 100 dwords aka 400 bytes(array of 100 dwords). rax contains pointer
    mov r15, rax                       ;saving pointer of array
    ;test program where we loop through the array and store 0 - 99 in each pos
    xor ebx, ebx
    ._L1:
       mov [r15 + rbx * 4], ebx
    ._L1Cond:
       inc ebx
       cmp ebx, 100                    ;when ebx reaches 100 we have reached the end of the array
       jl ._L1

    xor ebx, ebx
    ;print out the array
    ._L2:
       mov eax, [r15 + rbx * 4]
       push rax
       call _printInt
       add rsp, 8
       call _endl
    ._L2Cond:
       inc ebx
       cmp ebx, 100
       jl ._L2

    push r15
    call _free


    add rsp, 16                         ;clear the stack
    mov rax, 60                         ;SYSCALL_EXIT
    mov rdi, 0
    syscall

;(first)last argument pused onto the stack must be the amount of bytes
;if successfull then rax will contain pointer to the memory
_malloc:
   ;prolog
   push rbp
   mov rbp, rsp

   ;actual code
   cmp qword[rbp + 16], 0        ;compare with first argument
   jle ._mallocEpilog            ;if zero of negetive exit

   cmp qword[global_base], NULL  ;if the global_base pointer is "NULL" aka 0 allocate space
   jz  ._setGlobal_Base

   ;if global_base is not "NULL"
   push qword[rbp + 16]          ;how many bytes big does the block need to be
   push qword[global_base]       ;pointer to "meta_data" struct
   call ._findFreeBlock
   test rax, rax                 ;if zero no block was found. need to call ._requestSpace if zero
   jz ._needMoreSpace

   ;found free block
   mov rdx, rax                  ;save the pointer to memory block
   add rdx, block_meta.free      ;set the block to be not free
   mov byte[rdx], 0
   jmp ._mallocExit

   ._needMoreSpace:
   call ._requestSpace            ;we did not find a big enoug block. so make sapce
   jmp ._mallocExit


   ._setGlobal_Base:               ;will be used first time malloc is called
   push qword[rbp + 16]            ;how many bytes does the user want to reserve
   push NULL                       ;the global_base pointer has not been set
   call ._requestSpace
   mov [global_base], rax          ;save the pointer

   ._mallocExit:
   add rsp, 16                     ;clean the stack
   add rax, META_SIZE              ;add offset because of the "meta_block" struct

   ._mallocEpilog:
   ;epilog
   pop rbp
   ret

;(fist)last agument on the stack must be pointer to the last "block_meta" struct
;second argument must be the size in bytes that need to be allocated
;returns pointer to memory block in rax
._requestSpace:
   ;prolog
   push rbp
   mov rbp, rsp

   mov rdi, [rbp + 24]        ;how many bytes for the user
   add rdi, META_SIZE         ;extra bytes for meta data
   push rdi
   call ._sbrk                ;rax will contain the pointer
   add rsp, 8                 ;clear stack

   mov r8,  block_meta.next   ;putting the offsets in the register for later use
   mov r9,  block_meta.size
   mov r10, block_meta.free

   mov qword[rax + r8], NULL  ;just setting it to NULL to get rid of garbage data for the next

   cmp qword[rbp + 16], NULL  ;the last "block_meta" pointer is NULL then jmp
   jz ._fillMetaData

   mov rcx, [rbp + 16]        ;the current last "block_meta" struct in the list
   mov qword[rcx + r8], rax   ;mov pointer of allocated memory into next pointer of struct

   ._fillMetaData:            ;setting all the other fields in the struct
   mov rdi, [rbp + 24]        ;how many bytes for the user
   mov qword[rax + r9], rdi   ;setting the size field of the struct
   mov byte[rax + r10], 0     ;setting the free field to be 0 of struct

   ;epilog
   pop rbp
   ret

;(fist)last argument on the stack must be pointer to "block_meta" struct
;second argument is how big the block needs to be
;if successfull then rax will contain pointer to the block
;if failure the rax will contain pointer to the last block of "block_meta" struct
._findFreeBlock:
   ;prolog
   push rbp
   mov rbp, rsp

   mov rax, [rbp + 16]         ;pointer to the "block_meta" struct
   mov rdx, [rbp + 24]         ;how big do you need the block to be
   mov r8,  block_meta.next    ;offset
   mov r9,  block_meta.size
   mov r10, block_meta.free
   jmp ._findFreeBlockLoopCond

   ._findFreeBlockLoop:
      mov [rbp + 16], rax      ;save current pointer in argument 1
      mov rax, [rax + r8]      ;go to the next "block_meta" struct
   ._findFreeBlockLoopCond:
      test rax, rax            ;if rax is zero we have reached the end of the linked list. exit
      jz ._findFreeBlockExit
      cmp byte[rax + r10], 0   ;if zero then block is not empty. loop again
      jz ._findFreeBlockLoop
      cmp [rax + r9], rdx      ;if the current block has does not have enough space loop again.
      jl ._findFreeBlockLoop

   ._findFreeBlockExit:
   ;epilog
   pop rbp
   ret

;(fist)last argument must be how much space do you want to reserve
;return pointer in rax
._sbrk:
   ;prolog
   push rbp
   mov rbp, rsp

   ;actual code
   mov rax, SYSCALL_BRK       ;using brk to get initilial address
   mov rdi, [current_sbrk]    ;starts at 0. gets updated later
   syscall
   mov r8,  rax               ;save for later

   mov rax, SYSCALL_BRK
   mov rdi, [rbp + 16]        ;first argument (how many bytes)
   add rdi, r8                ;needs to start at teh address we saved
   syscall

   mov [current_sbrk], rax    ;next time will start at this address

   mov rax, r8                ;restore pointer to the memory

   ;epilog
   pop rbp
   ret

;(first)last arguemnt on the stack must be the pointer you want to deallocate memory for
_free:
   ;prolog
   push rbp
   mov rbp, rsp

   ;I will be calling the pointer in rax to be the "original block"
   mov rax, [rbp + 16]         ;pointer to memory that needs to be deallocated
   sub rax, META_SIZE          ;offset to find the "block_meta" struct

   mov rcx, rax
   add rcx, block_meta.free    ;offset to set free to be 1
   mov byte[rcx], 1

   ._freeEpilog:
   ;epilog
   pop rbp
   ret
;print methods for testing!
%define STDIN  0
%define STDOUT 1
%define STDERR 2

%define SYSCALL_READ     0
%define SYSCALL_WRITE    1
%define SYSCALL_EXIT     60

section .data
   endl db 10
   endlLength equ $ - endl

;no input needed
;just an end line "method"
_endl:
   mov rax, SYSCALL_WRITE
   mov rdi, STDOUT
   mov rsi, endl
   mov edx, endlLength
   syscall
   ret
   
   
 ;last value pushed to stack will be printed
_printInt:
   ;prolog
   push rbp
   mov rbp, rsp
   ;save registers
   push rbx

   ;actual code
   mov rsi, rsp
   mov rax, [rbp + 16]         ;get the value that user wants to print
   mov rbx, 10                 ;will be used to divide by 10 later
   xor rcx, rcx

   cqo
   cmp rdx, -1                 ;check to see if negetive
   jne _divisionLoop           ;if not negetive jump

   ;print negetive sign
   dec rsi
   mov [rsi], byte '-'
   mov rax, SYSCALL_WRITE
   mov rdi, STDOUT
   mov rdx, 1
   syscall
   inc rsi

   ;convert to positive number
   mov rax, [rbp + 16]         ;get the value that needs to be printed
   neg rax                     ;make it a positive
   xor rcx, rcx

   _divisionLoop:
      xor rdx, rdx
      div rbx                    ;divides number by 10 to move over last digit into rdx reg
      add dl, '0'                ;add the '0' to ascii to convert into ascii val
      dec rsi
      mov [rsi], dl
      inc rcx                    ;count for how many digits added to stack
   test rax, rax
   jnz _divisionLoop             ;jump if the division did not result in a zero

   ;print all the values
   mov rax, SYSCALL_WRITE
   mov rdi, STDOUT
   mov rdx, rcx
   syscall

   ;restore register
   pop rbx
   ;epilog
   pop rbp
   ret