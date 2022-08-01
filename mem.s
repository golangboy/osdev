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
    jmp $
_dwMCRNumber: dw 0   ;记录ARDS的数量
_MemChkBuf: times 256 db 0
times 510-($-$$) db 0
db 0x55
db 0xaa