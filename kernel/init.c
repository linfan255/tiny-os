#include "init.h"
#include "print.h"
#include "interrupt.h"

void init()
{
	put_str("init all\n");
	init_idt();
}
