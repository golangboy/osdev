org 0x7c00

;打开A20线
mov dx,0x92
in al,dx
or al,2
out dx,al

;CR0寄存器打开Page Enabled标志位
mov eax,cr0
or eax,1
mov cr0,eax

;加载GDT
lgdt [gdt_pointer]
;更改DS
mov ax,0x8
mov ds,ax
;更改CS
jmp 0x10:flush


[bits 32]
flush:
;PDE
mov eax,0x1F000
mov edi,eax
mov edx,0

;第一个PTE
add eax,0x1000
mov ebx,eax
or ebx,1
mov [edi],ebx
add edi,0x300*4
mov [edi],ebx

mov ecx,256
l:
;eax->pte
;edx->phy
mov ebx,edx
or ebx,1
mov [eax],ebx

add eax,4
add edx,0x1000

loop l

mov eax,0x1F000
mov cr3,eax

;打开页转换
mov eax,cr0
or eax,0x80000000
mov cr0,eax


jmp $


gdt_pointer:
dw 23
dd gdt_arrays
;GDT
gdt_arrays:
dq 0
dq 0xCF92000000FFFF
dq 0xCF9E000000FFFF

times 510-($-$$) db 0
db 0x55
db 0xaa