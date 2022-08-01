org 0x7c00

mov dx,0x1f6
mov al,0xa0
out dx,al

mov dx,0x1f7
mov al,0xec
out dx,al

not_ready2:
mov dx,0x1f7
in ax,dx
and al,0x08
cmp al,0x08
jnz not_ready2


mov si,stag1

mov cx,256
rrr:
mov dx,0x1f0
in ax,dx
mov [si],ax
add si,2
loop rrr



jmp $

; Debug



; Read Kernel From Floppy
mov ax,0
mov es,ax
mov ah,2
mov al,12
mov ch,0
mov cl,2
mov dh,0
mov dl,0
mov bx,stag2
int 0x13


; Switch Protected Mode
in al,0x92
or al,2
out 0x92,al

mov eax,cr0
or eax,1
mov cr0,eax

; Load Gdt
lgdt [gdt_pointer]
mov ax,2<<3
mov ds,ax
mov ss,ax

mov eax,0x8000
add eax,0x18
mov eax,[eax]
jmp 0x08:changecs

[bits 32]
changecs:
; JMP entry.c:main
push eax
call eax


; GDT
gdt_pointer:
dw 3*8-1
dd gdt_table

gdt_table:
dq 0
dq 0xCF9A000000FFFF
dq 0xCF92000000FFFF
times 510 - ($-$$) db 0
db 0x55
db 0xaa
stag1:
; 0x7e00
times 512 db 0
stag2:
; 0x8000