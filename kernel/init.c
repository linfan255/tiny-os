#include "init.h"
#include "print.h"
#include "interrupt.h"
#include "timer.h"

void init()
{
	put_str("init all\n");
	init_idt();		//初始化中断
	init_8253();	//初始化8253计数器，提高时钟中断发生频率
}
