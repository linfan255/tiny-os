#include "print.h"

void main() {
	put_str("hello linfan, I'm the kernel! nice to meet you.\n");
	init();
	asm volatile("sti");
	while(1);
}
