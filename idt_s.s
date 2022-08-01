; --------------------------------------------------
; 	将 IDT 地址 载入 IDTR
;
; 	hurley 2013/11/07
;
;---------------------------------------------------
extern common_idt_function
extern mykeyboard
[GLOBAL idt_flush]
[GLOBAL install]
[GLOBAL closeint]
[GLOBAL starthlt]
[GLOBAL keyboard]
idt_flush:
	mov eax, [esp+4]  ; 参数存入 eax 寄存器
	lidt [eax]        ; 加载到 IDTR
	ret
.end:

install:
	cli
	pushad
	call common_idt_function
	; 	outb(0x20, 0x20);
	popad
	sti
	iret
.end:

keyboard:
	cli
	call mykeyboard
	sti
	iret
.end:


closeint:
	mov al,0x20
	mov dx,0x20
	out dx,al
	mov bx,0xa0
	mov dx,bx
	out dx,al
	ret

starthlt:
	hlt
; eflags
; cs
; eip
; eax
; ecx
; edx
; ebx
; esp
; ebp
; esi
; edi