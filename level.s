org 0x7c00

;
mov ax,0x92
mov dx,ax
in ax,dx
or ax,2
out dx,ax
;

;
mov eax,cr0
or eax,1
mov cr0,eax
;
lgdt [gdtptr]
lidt [idtptr]
mov ax,0x48
ltr ax
; mov ax,0x10
; mov ds,ax
; mov ax,[gdtptr]

jmp 0x8:switch8
[bits 32]
switch8:
    ;;
    
    mov ax,(7<<3)|(0)
    mov ds,ax
    mov ax,(6<<3)|(0)
    mov ss,ax
    jmp 0x8:fuck
    jmp $
;
fuck:
    ; mov ax,0x8
    ; mov ds,ax
    ; mov ax,ds:0
    xor eax,eax
    mov eax,r3
    mov ebx,(5<<3)|(3);;cs
    ;;SS
    push (7<<3)|(3)   ;;ss
    push 0xffff
    pushf
    push ebx
    push eax
    iret
    jmp fuck
r3:
    ;;进入到了ring3
    ;;jmp 0x20:r0
    int 3
    nop
    xor eax,eax
    xor ebx,ebx
    jmp r3
r2:
    ;;进入到了ring2
    int 2
    nop
    xor eax,eax
    xor ebx,ebx
    int 0
    jmp r2
r0:
    jmp 0x8:r0
donothing:
    jmp $
idt_func:
    jmp $
gdtptr:
    dw 79
    dd gdt_array
gdt_array:
    dq 0                ;;0
    dq 0xCF9E000000FFFF ;;8     一致性 r0
    dq 0xCFDE000000FFFF ;;10    一致性 r2
    dq 0xCFFE000000FFFF ;;18          r3
    dq 0xCF9E000000FFFF ;;20    一致性r0
    dq 0xCFFE000000FFFF ;;ring3 一致性
    dq 0xCF92000000FFFF ;;ring0 数据
    dq 0xCFF2000000FFFF ;;ring3 数据
    ;dq 0xCFF2000000FFFF ;;ring3 stack
    
    dw donothing
    dw 0x8
    db 0
    db 0xec
    dw 0
    


    ;tss
    dw 103
    dw tss
    db 0
    db 137
    db 16
    db 0

    ;
    ; dq 0xCFEC000000FFFF ;;rin3 调用门

idtptr:
    dw 4*8-1
    dd idt_array 
idt_array:
    dw r0
    dw 0x8  ;;GDT的
    db 0
    db 0xEE ;;自身的
    dw 0

    dw r0
    dw 0x8
    db 0
    db 0xee
    dw 0

    dw r0
    dw 0x8
    db 0
    db 0xee
    dw 0


    dw 0
    dw 9<<3
    dw 0xE500
    dw 0



tss:
    dd 0       ;last tss
    dd 0xaaaa  ;esp0
    dd 8<<3    ;ss0
    dd 0xbbbb ;esp1
    dd 8<<3 ;ss1
    dd 0xccc ;esp2
    dd 8<<3 ;ss2
    dd 0 ;cr3
    dd 0 ;eip
    dd 0 ;eflags
    dd 0 ;eax
    dd 0 ;ecx
    dd 0 ;edx
    dd 0 ;ebx
    dd 0 ;esp
    dd 0 ;ebp
    dd 0 ;esi
    dd 0 ;edi
    dd 0 ;es
    dd 0 ;cs
    dd 0 ;ss
    dd 0 ;ds
    dd 0 ;fs
    dd 0 ;gs
    dd 0 ;ldt selector
    dd 0 ;io map

times 510-($-$$) db 0
db 0x55
db 0xaa

;rsp = ffff
;cs 2a   ss 42  ds 0  flags 0x46  tr 0x48

;cs a   ss 42  ds 0  
;fff3

;r3此时的eflags
;r3执行中断时的cs选择子
;r3执行中断的下一条执行


;rsp=ffff
;cs 2b ss 43 tr 48 ef 46

;fff3
;cs b
;ss 43