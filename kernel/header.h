#ifndef __KERNEL_HEADER_H
#define __KERNEL_HEADER_H

#define RPL0 0
#define RPL1 1
#define RPL2 2
#define RPL3 3

#define GDT_TI 000
#define LDT_TI 100

#define SELECTOR_CODE (1 << 3) + GDT_TI + RPL0

#define DPL0 0X00
#define DPL1 0X01
#define DPL2 0X10
#define DPL3 0X11

#define ATRRI16 0X06
#define ATRRI32 0X0e

#define ATRRI32_DPL0 (1 << 7) + (DPL0 << 5) + ATRRI32 

#endif
