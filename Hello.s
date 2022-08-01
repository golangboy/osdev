org 0x7c00




stop:

; A20
in al,0x92
or al,0000_0010b
out 0x92,al

; CR0
mov eax,cr0
or eax,1
mov cr0,eax

lgdt [gdt_array]
mov ax,0x08
mov ss,ax
mov ds,ax
jmp 0x8:fuck

nop
gdt_array:
	dw 15
	dd real
real:
	dd 0x0000000
	dd 0x0000000
	
	dd 0x0000FFFF
	dd 0x00CF9E00

idt_array:
	dw 36*8-1
	dd rrea
rrea:
	dq 0xAE0000087D71
	dq 0xAE0000087D71
	dq 0xAE0000087D71
	dq 0xAE0000087D71
	times 28 dq 0xAE0000087D71	
	dq 0xAE0000087DA8
	dq 0xAE0000087DA8
	dq 0xAE0000087DA8
	dq 0xAE0000087DA8
[bits 32]
fuck:
	mov eax,idt_array
	lidt [idt_array]
	mov eax,myfunc
	int 33
yy:
	jmp yy
myfunc:
	mov eax,timefunc
	nop
	mov al,0x11
	out 0x20,al
	out 0xa0,al

	mov al,0x20
	out 0x21,al

	mov al,0x28
	out 0xa1,al
	
	mov al,0x4
	out 0x21,al

	mov al,0x02
	out 0xa1,al

	mov al,0x01
	out 0x21,al
	out 0xa1,al

	mov al,0
	out 0x21,al
	out 0xa1,al

	; mov al,0x36
	; out 0x43,al

	; mov al,0x54
	; out 0x40,al

	; mov al,0x02
	; out 0x40,al
	; sti
rr:
	jmp rr
timefunc:

	jmp timefunc
times 510-($-$$) db 0
db 0x55,0xaa