%include "boot.inc"
section loader vstart=LOADER_BASE_ADDR
LOADER_STACK_TOP equ LOADER_BASE_ADDR
jmp loader_start

;==============构建全局描述符表需要用的定义====================
	GDT_BASE:				;最开始的描述符无法使用，都定义成0
	dd 0x00000000
	dd 0x00000000
	
	GDT_CODE:				;该段描述符是代码段
	dd 0x0000ffff
	dd DESC_CODE_HIGH4
	
	GDT_DATA:				;数据段和栈段
	dd 0x0000ffff
	dd DESC_DATA_HIGH4
	
	GDT_VIDEO:				;显存段
	dd 0x80000007
	dd DESC_VIDEO_HIGH4
	
	GDT_SIZE equ $ - GDT_BASE
	GDT_LIMIT equ GDT_SIZE - 1
	
	times 60 dq 0			;预留额外的空间给后来的全局描述符表
	
	
	
			 
	SELECTOR_CODE equ (0x0001 << 3) + TI_GDT + RPL0 ;定义一些选择子
	SELECTOR_DATA equ (0x0002 << 3) + TI_GDT + RPL0
	SELECTOR_VIDEO equ (0x0003 << 3) + TI_GDT + RPL0
	
	gdt_ptr  dw GDT_LIMIT
			 dd GDT_BASE	;构建指向全局描述符表的“指针”

;========================打印字符串=================================
	msg db "2 loader"

loader_start:
	mov cx,8
	mov ax,0xb800
	mov gs,ax
	mov di,3200

	mov ax,cs
	mov fs,ax
	mov si,msg
printmsg:
	mov al,[fs:si]
	mov ah,0xa4
	mov [gs:di],ax
	add di,2
	inc si
	loop printmsg

	

;================切换到保护模式==================

	;-----------1、打开A20线---------------
	in al,0x92
	or al,00000010b
	out 0x92,al
	
	;-----------2、加载GDT----------------
	lgdt [gdt_ptr]
	
	;-----------3、cr0第0位置1-----------
	mov eax,cr0
	or eax,0x00000001
	mov cr0,eax
	
	;为了刷新流水线，注意此时已经是处于保护模式下，故开始的段寄存器替换成选择子
	jmp dword SELECTOR_CODE:p_mode_start
	
[bits 32]
p_mode_start:
	mov ax, SELECTOR_DATA
	mov ds, ax
	mov es, ax
	mov ss, ax
	mov esp, LOADER_STACK_TOP
	mov ax, SELECTOR_VIDEO
	mov gs, ax
	
	mov byte [gs:320],'L'
	
	jmp $
