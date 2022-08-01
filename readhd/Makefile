all:
	nasm boot.s
	x86_64-elf-gcc -m32 -c -ggdb -gstabs+ -nostdinc -fno-builtin -fno-stack-protector *.c
	x86_64-elf-ld *.o -e main -m elf_i386 -T kernel.ld
	dd if=a.out of=boot seek=1 bs=512