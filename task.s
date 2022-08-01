global switch_task
global switch_0
switch_task:
    mov eax,[esp+4]
    mov ebx,[eax+8]
    mov ecx,[eax+12]
    mov edx,[eax+16]
    mov esp,[eax+20]
    add esp,12
    mov ebp,[eax+24]
    mov esi,[eax+28]
    mov edi,[eax+32]
    push dword [eax]
    push dword [eax+40]
    popf
    mov eax,[eax+4]
    sti
    ret
switch_0:
    cli
; typedef struct task
; {
; 	int eip; 0x15b3 0
; 	int eax; 0x1 4
; 	int ebx; 0xfff7 8
; 	int ecx; 0x001fffff 12
; 	int edx; 0xffffffff 16
; 	int esp; 0x0000ffc4 20
; 	int ebp; 0x0000ffe8 24
; 	int esi; 0x000e0000 28
; 	int edi; 0x00007d73 32
; 	int cs;  0x00000008 36
;     int cflags; 40
; } task;