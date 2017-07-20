#include "header.h"
#include "stdint.h"
#include "interrupt.h"
#include "print.h"
#include "io.h"

#define DESC_CNT 33

extern void* int_entry_table[DESC_CNT];	//里面保存的是中断处理函数的入口(即调用中断处理程序的代码块)
void* int_table[DESC_CNT];	//保存的是中断处理程序的地址
char* int_name[DESC_CNT];	//保存中断名字，以便将来调试用
struct Intr_desc intr_desc_table[DESC_CNT];

static void interrupt_handler(uint8_t vec_no)	//暂时的中断处理函数，只是简单打印出信息而已
{
	if(vec_no == 0x27 || vec_no == 0x2f)
		return;								//忽略0x27的伪中断，0x2f则为保留项
	
	put_str("int vector 0x");
	put_int(vec_no);
	put_char(':');
	put_str(int_name[vec_no]);
	put_char('\n');
}

static void exception_init()
{
	put_str("init interrupt entry table\n");
	int i;
	for(i = 0; i < DESC_CNT; i++) {
		int_name[i] = "unknown";
		int_table[i] = interrupt_handler;
	}
	//为19个已知中断赋予名字，以便调试
	int_name[0] = "Divide error";
	int_name[1] = "Debug";
	int_name[2] = "NMI interrupt";
	int_name[3] = "Breakpoint";
	int_name[4] = "Overflow";
	int_name[5] = "Bound range exceeded";
	int_name[6] = "Invalid Opcode";
	int_name[7] = "Device Not Avaliable";
	int_name[8] = "Double fault";
	int_name[9] = "CoProcessor Segment over run";
	int_name[10] = "Invalid TSS";
	int_name[11] = "Segment not present";
	int_name[12] = "Stack segment fualt";
	int_name[13] = "General Protection";
	int_name[14] = "Page fault";
	
	int_name[16] = "Floating Point Error";
	int_name[17] = "Alignment check";
	int_name[18] = "Machine check";
	int_name[19] = "simd floating-point exception";
	put_str("init interrupt entry table end\n");
}

static void init_desc_table()
{
	int i;
	for(i = 0; i < DESC_CNT; i++) {
		intr_desc_table[i].offset_low16 = (uint32_t)int_entry_table[i] & 0x0000ffff;
		intr_desc_table[i].selector = SELECTOR_CODE;
		intr_desc_table[i].atrribute = (ATRRI32_DPL0 << 8) + 0;
		intr_desc_table[i].offset_high16 = (uint32_t)int_entry_table[i] & 0xffff0000;
	}

	put_str(" init descriptor table done!\n");
}

static void init_8259a()
{
	//设置ICW1，需要写入主片0x20，从片0xa0
	outb(0x20, 0x11); //设置成边沿触发
	outb(0xa0, 0x11);

	//设置ICW2，即起始中断向量号，写入到主片0x21，从片0xa1
	outb(0x21, 0x20); //查阅资料，0～31中断号保留，从32开始
	outb(0xa1, 0x28);

	//设置ICW3，设置从主片IRQ接口，写入到0x21, 0xa1
	outb(0x21, 0x04);	//IR2接从片
	outb(0xa1, 0x02);	//接主片的IR2

	//设置ICW4，写入到0x21, 0xa1
	outb(0x21, 0x01);	//x86模式、手动结束中断
	outb(0xa1, 0x01);

	//打开主片上的时钟中断
	outb(0x21, 0xfe);
	outb(0xa1, 0xff);

	put_str(" pic init done\n");
}

void init_idt() //初始化中断的函数
{
	put_str("init start\n");
	init_desc_table();
	exception_init();
	init_8259a();

	//加载到idtr
	uint64_t idtr = (uint64_t)((uint32_t)intr_desc_table << 16) + (sizeof(intr_desc_table) - 1);
	asm volatile("lidt %0": :"m" (idtr));
	put_str("idt init done\n");
}



















