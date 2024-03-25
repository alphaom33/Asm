nasm -f elf64 -o ohno.o fizzbuzz.asm
ld ohno.o -lc -I /lib64/ld-linux-x86-64.so.2
./a.out