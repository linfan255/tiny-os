[bits 32]
%define ERRORCODE nop
%define PUSH0	push 0

extern put_str

section .data
	printstr db "interrupt here!", 0xa, 0

global int_entry_table
int_entry_table:

%macro VECTOR 2
section .text
int%1_entry:
	%2				;如果该类型中断压入了错误码，此处被编译为nop
	push printstr	;如果没有压入错误码，那么此处为了后面的编码，应该编译成push 0
	call put_str
	add esp, 4

	;手动模式，必须手动向其发送结束信号，OCW2 TO 0x20 0xa0
	mov al, 0x20	;EOI位为1，其它为0
	out 0x20, al
	out 0xa0, al
	add esp, 4		;跨国错误码或者0
	iret

section .data
	dd int%1_entry
%endmacro

VECTOR 0, PUSH0
VECTOR 1, PUSH0
VECTOR 2, PUSH0
VECTOR 3, PUSH0
VECTOR 4, PUSH0
VECTOR 5, PUSH0
VECTOR 6, PUSH0
VECTOR 7, PUSH0
VECTOR 8, ERRORCODE 
VECTOR 9, PUSH0
VECTOR 10, ERRORCODE 
VECTOR 11, ERRORCODE 
VECTOR 12, PUSH0
VECTOR 13, ERRORCODE 
VECTOR 14, ERRORCODE 
VECTOR 15, PUSH0
VECTOR 16, PUSH0
VECTOR 17, ERRORCODE 
VECTOR 18, PUSH0
VECTOR 19, PUSH0
VECTOR 20, PUSH0
VECTOR 21, PUSH0
VECTOR 22, PUSH0
VECTOR 23, PUSH0
VECTOR 24, ERRORCODE
VECTOR 25, PUSH0
VECTOR 26, ERRORCODE
VECTOR 27, ERRORCODE
VECTOR 28, PUSH0
VECTOR 29, ERRORCODE
VECTOR 30, ERRORCODE
VECTOR 31, PUSH0
VECTOR 32, PUSH0
	

