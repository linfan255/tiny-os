#ifndef __KERNEL_INTERRUPT_H
#define __KERNEL_INTERRUPT_H

struct Intr_desc
{
	uint16_t offset_low16;	//中断处理程序在目标代码段内的偏移量15~0
	uint16_t selector;		//中断处理程序目标代码段选择子--0x1
	uint16_t atrribute;		//属性，可参见中断描述符格式
	uint16_t offset_high16; //中断处理程序在目标代码段内的偏移量32~16
};

void init_idt();

#endif
