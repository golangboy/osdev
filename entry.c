#include "console.h"
// 端口写一个字节
void outb(uint16_t port, uint8_t value);

// 端口读一个字节
uint8_t inb(uint16_t port);

// 端口读一个字
uint16_t inw(uint16_t port);

void init_idt();
void install();
void init_8259();
extern void idt_flush(uint32_t);
void common_idt_function();
void test();
void starthlt();
void keyboard();
// 中断描述符
typedef struct idt_entry_t
{
	uint16_t base_lo; // 中断处理函数地址 15～0 位
	uint16_t sel;	  // 目标代码段描述符选择子
	uint8_t always0;  // 置 0 段
	uint8_t flags;	  // 一些标志，文档有解释
	uint16_t base_hi; // 中断处理函数地址 31～16 位
} __attribute__((packed)) idt_entry_t;

// IDTR
typedef struct idt_ptr_t
{
	uint16_t limit; // 限长
	uint32_t base;	// 基址
} __attribute__((packed)) idt_ptr_t;

idt_entry_t idts[40];
idt_ptr_t pidt;

void init_timer(uint32_t frequency)
{
	// 注册时间相关的处理函数
	// register_interrupt_handler(IRQ0, timer_callback);

	// Intel 8253/8254 PIT芯片 I/O端口地址范围是40h~43h
	// 输入频率为 1193180，frequency 即每秒中断次数
	uint32_t divisor = 1193180 / frequency;

	// D7 D6 D5 D4 D3 D2 D1 D0
	// 0  0  1  1  0  1  1  0
	// 即就是 36 H
	// 设置 8253/8254 芯片工作在模式 3 下
	outb(0x43, 0x36);

	// 拆分低字节和高字节
	uint8_t low = (uint8_t)(divisor & 0xFF);
	uint8_t hign = (uint8_t)((divisor >> 8) & 0xFF);

	// 分别写入低字节和高字节
	outb(0x40, low);
	outb(0x40, hign);
}

typedef struct mem_block
{
	int baselow32;
	int basehigh32;
	int lenlow32;
	int lenhigh32;
	int type;
} mem_block;
void task1();
void task2();
void fun();
int waitIde()
{
	int al = 0;
	while (al = inb(0x1f7) !=0x50);
	return al;
}
short pw[256];
void readIde()
{
	int al;
	int i;
			console_write("O0000k111k...\n");
	waitIde();
	outb(0x1F6, 0xA0);
	outb(0x1F7, 0xEC);
		console_write("Ok111k...\n");
	while (al = inb(0x1f7) !=0x58);
	for (i = 0; i < 256; i++)
	{
		pw[i] = inw(0x1F0);
	}
	console_write("Okkk...\n");
}
int main(int *a, mem_block *b)
{
	asm volatile("cli");
	readIde();
	while(1);


	console_clear();
	console_write("Loading Kernel...\n");
	init_idt();
	console_write("IDT Finish...\n");
	// test();
	console_write("Return...\n");
	console_write("Initing 8259A...\n");

	init_8259();
	// init_timer(100);
	//  console_write_dec(*a, rc_black, rc_red);
	console_write("Physical memory :");
	int total = 0;
	for (int z = 0; z < *a; z++)
	{

		total += (b->lenlow32);
		b++;
	}
	console_write_dec(total, rc_black, rc_red);
	console_write("Bytes \n");

	// start_task(task1, 0x1ffff);
	// start_task(task2, 0x2ffff);
	asm volatile("sti");
	// fun();
	// test();
	closeint();
	while (1)
		;
	return 0;
}
void test()
{
	// asm("int $33");
	for (int i = 0; i < 6000; i++)
	{
		static uint32_t tick = 0;
		// console_write_dec(tick++,rc_black,rc_blue);
		// console_write("IDT Finish...\n");
		console_write_dec(i, rc_black, rc_red);
		console_write("\n");
	}
}
void init_idt()
{
	for (int i = 0; i < sizeof(idts) / sizeof(idt_entry_t); i++)
	{
		idts[i].base_lo = (int)install & 0xffff;
		idts[i].always0 = 0;
		idts[i].sel = 8;
		idts[i].flags = 0x8e;
		idts[i].base_hi = (((int)install) >> 16) & 0xffff;
	}
	// keyboard
	idts[33].base_lo = (int)keyboard & 0xffff;
	idts[33].base_hi = (((int)keyboard) >> 16) & 0xffff;

	pidt.base = idts;
	pidt.limit = sizeof(idts) - 1;

	idt_flush(&pidt);
}

void mykeyboard()
{
	char aa = inb(0x60);
	console_write_hex(aa, rc_black, rc_green);
	console_write("\n");
	closeint();
}

typedef struct task
{
	int eip;
	int eax;
	int ebx;
	int ecx;
	int edx;
	int esp;
	int ebp;
	int esi;
	int edi;
	int cs;
	int cflags;
	int valid;
	// int id;
} task;

task task_sets[100];
int task_count = 0;
int current_task = -1;
void finish();
extern void switch_0();
void start_task(int address, int *stack)
{
	asm volatile("cli");
	*(stack) = &task_sets[++task_count];
	stack--;
	*(stack) = 0; // ret address , we do not need this
	stack--;
	*(stack) = finish;
	task_sets[task_count].eip = address;
	task_sets[task_count].esp = stack;
	task_sets[task_count].esp -= 12;
	task_sets[task_count].eax = 1;
	task_sets[task_count].ebx = 2;
	task_sets[task_count].ecx = 3;
	task_sets[task_count].edx = 4;
	task_sets[task_count].edi = 5;
	task_sets[task_count].esi = 6;
	task_sets[task_count].ebp = 7;
	task_sets[task_count].cflags = 0x0;
	task_sets[task_count].valid = 1;
	asm volatile("sti");
}
void task1()
{
	// while (1)
	//{
	int sum = 0;
	for (int i = 0; i <= 10000; i++)
	{
		sum += i;
		console_write("task1 !!\n");
	}

	// console_write_dec(sum, rc_black, rc_red);
	// }
}
void task2()
{
	for (int i = 0; i <= 10000; i++)
	{
		// sum+=i;
		console_write("task2!!\n");
	}
}
__attribute__((naked)) void fun()
{
	asm volatile("add $0x4,%esp");
	fun();
}

void finish(task *t)
{
	// switch_task(&task_sets[0]);
	t->valid = 0;
	console_write_dec(t, rc_black, rc_red);
	while (1)
	{
	}

	// asm volatile("hlt");
	// console_write("a task finish !!\n");
	// starthlt();
}
// ; eflags
// ; cs
// ; eip
// ; eax
// ; ecx
// ; edx
// ; ebx
// ; esp
// ; ebp
// ; esi
// ; edi
extern void switch_task(task *t);
extern void closeint();
void common_idt_function(int edi, int esi, int ebp, int esp, int ebx, int edx, int ecx, int eax, int eip, int cs, int flags)
{
	// console_clear();
	// static uint32_t tick = 0;
	// console_write_dec(tick++, rc_black, rc_red);

	// console_write("\n");
	//  printk_color(rc_black, rc_red, "Tick: %d\n", tick++);
	asm volatile("cli");
	// 调度器
	if (current_task == -1)
	{
		current_task = 0;
		task_sets[current_task].valid = 1;
		task_count++;
	}
	task_sets[current_task].eip = eip;
	task_sets[current_task].edi = edi;
	task_sets[current_task].esi = esi;
	task_sets[current_task].ebp = ebp;
	task_sets[current_task].esp = esp;
	task_sets[current_task].ebx = ebx;
	task_sets[current_task].edx = edx;
	task_sets[current_task].ecx = ecx;
	task_sets[current_task].eax = eax;
	task_sets[current_task].cs = cs;
	task_sets[current_task].cflags = flags;
	// asm volatile("sti");
	//当前这个任务的环境已经保存好了，切换到下一个任务的环境就行了

	current_task = (current_task + 1) % (task_count);
	while (0 == task_sets[current_task].valid && current_task != 0)
	{
		current_task = (current_task + 1) % (task_count);
	}
	closeint();
	//下一个任务
	switch_task(&task_sets[current_task]);
}

// 端口写一个字节
inline void outb(uint16_t port, uint8_t value)
{
	asm volatile("outb %1, %0"
				 :
				 : "dN"(port), "a"(value));
}

// 端口读一个字节
inline uint8_t inb(uint16_t port)
{
	uint8_t ret;

	asm volatile("inb %1, %0"
				 : "=a"(ret)
				 : "dN"(port));

	return ret;
}

// 端口读一个字
inline uint16_t inw(uint16_t port)
{
	uint16_t ret;

	asm volatile("inw %1, %0"
				 : "=a"(ret)
				 : "dN"(port));

	return ret;
}
void init_8259()
{
	// 重新映射 IRQ 表
	// 两片级联的 Intel 8259A 芯片
	// 主片端口 0x20 0x21
	// 从片端口 0xA0 0xA1

	// 初始化主片、从片
	// 0001 0001
	outb(0x20, 0x11);
	outb(0xA0, 0x11);

	// 设置主片 IRQ 从 0x20(32) 号中断开始
	outb(0x21, 0x20);
	// 设置从片 IRQ 从 0x28(40) 号中断开始
	outb(0xA1, 0x28);

	// 设置主片 IR2 引脚连接从片
	outb(0x21, 0x04);
	// 告诉从片输出引脚和主片 IR2 号相连
	outb(0xA1, 0x02);

	// 设置主片和从片按照 8086 的方式工作
	outb(0x21, 0x01);
	outb(0xA1, 0x01);

	// 设置主从片允许中断
	outb(0x21, 0xFD);
	outb(0xA1, 0x0);
}