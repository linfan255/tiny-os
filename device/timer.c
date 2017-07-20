#include "timer.h"
#include "stdint.h"
#include "io.h"

#define CONTRL_PORT8253 0x43
#define COUNTER0_PORT 0x40
#define COUNTER1_PORT 0x41
#define COUNTER2_PORT 0x42
#define COUNTER0 0
#define COUNTER1 1
#define COUNTER2 2
#define RW0	0
#define RW1 1
#define RW2 2
#define RW3 3
#define MODE0 0
#define MODE1 1
#define MODE2 2
#define MODE3 3
#define MODE4 4
#define MODE5 5
#define BCD0 0
#define BCD1 1
#define STD_FREQ 1193180
#define MY_CLK_CNT 100 //用户自己想设定的每秒钟时钟中断发生的次数
#define INIT_VALUE STD_FREQ / MY_CLK_CNT

//该方法是对计数定时器8253做初始话，以达到修改时钟中断发生的频率
void init_8253() {
	//1:往控制字寄存器写入控制字信息
	//其中选定的是工作模式2,因为这时候为分频器，每n个时钟脉冲便会产生一个out端的信号
	outb(CONTRL_PORT8253, (uint8_t)(((uint8_t)COUNTER0 << 6) | ((uint8_t)RW3 << 4) | ((uint8_t)MODE2 << 1)));

	//2：写入计数器初始值n
	outb(COUNTER0_PORT, (uint8_t)INIT_VALUE);
	outb(COUNTER0_PORT, (uint8_t)INIT_VALUE >> 8);
	put_str("timer init end\n");
}
