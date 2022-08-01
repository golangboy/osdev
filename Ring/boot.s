org 0x7c00

;①进入保护模式
mov dx,0x92
in al,dx
or al,2
out dx,al

mov eax,cr0
or eax,1
mov cr0,eax

;②加载GDT
lgdt [gdt_pointer]
mov ax,0x10
mov ds,ax
mov ss,ax

;TSS
mov ax,0x30
ltr ax
jmp 0x8:flush


[bits 32]
flush:
;③加载中断
lidt [idt_pointer]

;④利用iret改变特权级，从ring0进入ring3特权级
push (4<<3) | (3)  ;;SS 对应到第五个GDT项，DPL=3的数据段
push 0xffff        ;;ESP
push 0x2           ;;EFLAGS
push (3<<3) | (3)  ;;CS 对应到第四个GDT项，DPL=3到代码段
push ring3         ;;EIP
iret
jmp $

ring3:
mov ax,4<<3        ;;DS 对应到第五个GDT项,DPL=3
mov ds,ax
;⑤使用中断尝试进入到ring0特权级
int 0

jmp $

idt_function:
;问题：上面中断调用后，此时CPU在这里执行了，但是CPL还是3，特权级还是没改变

nop

hlt_func:
; lgdt [gdt_pointer]
jmp $

jmp $

call_func:
jmp $

;;=================数据区了==================
;;GDT
gdt_pointer:
dw 55
dd gdt_arrays

gdt_arrays:
dq 0
dq 0xCF9A000000FFFF ;代码段，可读可执行，一致性，DPL=0
dq 0xCF92000000FFFF ;数据段，可读可写，向上扩展，DPL=0
dq 0xCFFA000000FFFF ;代码段，可读可执行，一致性，DPL=3
dq 0xCFF2000000FFFF ;数据段，可读可写，向上扩展，DPL=3

dw call_func
dw 1<<3
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

tss:
    dd 0       ;last tss
    dd 0xaaaa  ;esp0
    dd 2<<3    ;ss0
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

;;IDT
idt_pointer:
dw 1*8-1
dd idt_arrays

idt_arrays:
;为了简单，这里只构造一个中断项
dw idt_function
dw 1<<3 ;;段选择子
db 0
db 0xee ;;DPL=3，系统段，中断门
dw 0

times 29 dq 0x0000ee0000087c46

times 510-($-$$) db 0
db 0x55
db 0xaa
;;=================数据区了==================