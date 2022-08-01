
org 0x7c00

;当前处于实模式
	mov ebx,0
    mov edx,0
	mov di,_MemChkBuf ;请忽略es,假设已经正确设置好了
.loop:
	mov eax,0e820h
	mov ecx,20
	mov edx,0534D4150h ;'SMAP'
	int 15h

	jc LABEL_MEM_CHK_FAIL ;检查CF，是否发生错误
	add di,20	;由于执行INT 15h之后es和di不发生改变，就需要手动修改
	inc dword [_dwMCRNumber] ;记录ARDS的数量
	cmp ebx,0;判断是否到达最后一个内存区域

	jne .loop
	jmp LABEL_MEM_CHK_OK ;ebx=0到达最后一个内存区域
LABEL_MEM_CHK_FAIL:
	mov dword [_dwMCRNumber],0
LABEL_MEM_CHK_OK:
;     jmp $

; 扇区数
mov ax,0x1f2
mov dx,ax
mov ax,0xff
out dx,al

;0-7
mov ax,0x1f3
mov dx,ax
mov ax,0
out dx,al

;8-15
mov ax,0x1f4
mov dx,ax
mov ax,0
out dx,al

;16-23
mov ax,0x1f5
mov dx,ax
mov ax,0
out dx,al

;24-27
mov ax,0x1f6
mov dx,ax
mov ax,0xe0
out dx,al

;请求读
mov ax,0x1f7
mov dx,ax
mov ax,0x20
out dx,al

not_ready:
;检测状态
in al,dx
and al,0x08
cmp al,0x08
jnz not_ready


;读取次数
mov cx,65280

;写入的位置
mov bx,0x000

read:
;开始读取数据
mov ax,0x1f0
mov dx,ax
in ax,dx
mov [bx],ax
add bx,2
loop read

nothing:
jmp protect_mode



protect_mode:
    ;A20
    mov byte ax,0x92
    mov dx,ax
    in ax,dx
    or ax,2
    out dx,ax

    mov eax,cr0
    or eax,1
    mov cr0,eax
    mov bx,gdt
    lgdt [bx]
    mov ax,0x10
    mov ds,ax
    mov ss,ax
    jmp 11:to_main

nt:
    jmp nt
gdt:
dw 23
dd gdt_array

gdt_array:
dq 0
dq 0xCF9E000000FFFF
dq 0xCF92000000FFFF

to_main:
[bits 32]
mov eax,0x18
mov eax, [eax]
mov ebp,0
mov esp,0xffff


push dword _MemChkBuf
push dword _dwMCRNumber
call eax
add esp,8
st:
jmp st
_dwMCRNumber: dw 0   ;记录ARDS的数量
_MemChkBuf: times 256 db 0
times 510-($-$$) db 0
db 0x55
db 0xaa