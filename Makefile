all:
	nasm Hello.s
	dd if=Hello of=floppy.img
	# qemu-system-x86_64 -fda floppy.img -boot a
	bochs -q -f bs 
sec:
	nasm idt_s.s -f elf -g -F stabs
	nasm task.s -f elf -g -F stabs
	nasm boot.s -l bootdbg
	x86_64-elf-gcc -m32 -c -ggdb -gstabs+ -nostdinc -fno-builtin -fno-stack-protector entry.c
	x86_64-elf-gcc -m32 -c -ggdb -gstabs+ -nostdinc -fno-builtin -fno-stack-protector console.c
	# x86_64-elf-ld *.o -e main -m elf_i386 -Ttext 0x1000
	x86_64-elf-ld *.o -e main -m elf_i386 -T kernel.ld
	
	dd if=boot of=floppy.img
	dd if=a.out of=kernel conv=notrunc
	# qemu-system-x86_64 -fda floppy.img -boot a
	bochs -q -f bs 
build:
	nasm Hello.s
clean:
	rm *.o
	rm a.out
	rm Hello
kernel:
	x86_64-elf-gcc -c -m32 entry.c
