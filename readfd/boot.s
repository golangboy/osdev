org 0x7c00
mov ax,0
mov es,ax
mov ah,2
mov al,1
mov ch,0
mov cl,2
mov dh,0
mov dl,0
mov bx,stag1
int 0x13
jmp $
times 510-($-$$) db 0
db 0x55
db 0xaa

stag1:
times 512 db 1
times 512 db 2