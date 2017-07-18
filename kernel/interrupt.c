#include "header.h"
#include "stdint.h"
#include "interrupt.h"
#include "print.h"
#include "io.h"

#define DESC_CNT 33

extern void* int_entry_table[DESC_CNT];
struct Intr_desc intr_desc_table[DESC_CNT];

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
	outb(0xa1, 0x04);	//接主片的IR2

	//设置ICW4，写入到0x21, 0xa1
	outb(0x21, 0x01);	//x86模式、手动结束中断
	outb(0xa1, 0x01);

	//打开主片上的时钟中断
	outb(0x21, 0xfe);
	outb(0xa1, 0xff);

	put_str(" pic init done\n");
}

void init_idt()
{
	put_str("init start\n");
	init_desc_table();
	init_8259a();

	//加载到idtr
	uint64_t idtr = (uint64_t)((uint32_t)intr_desc_table << 16) + (sizeof(intr_desc_table) - 1);
	asm volatile("lidt %0": :"m" (idtr));
	put_str("idt init done\n");
}

