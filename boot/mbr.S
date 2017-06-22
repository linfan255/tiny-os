;主引导程序
%include "boot.inc"

SECTION MBR vstart=0x7c00
	mov ax,cs
	mov ds,ax
	mov es,ax
	mov ss,ax
	mov fs,ax
	mov sp,0x7c00
	mov ax,0xb800
	mov es,ax

	;滚屏,调用0x10号中断
	mov ax,0x600
	mov bx,0x700
	mov cx,0
	mov dx,0x184f

	int 0x10

	;向屏幕输出message中的内容,es:di指向显存内容,ds:si指向字符串内容
	mov si,message
	mov di,0
	mov cx,5
mbrPrintLop:
	mov al,[ds:si]
	mov ah,0xa4
	mov [es:di],ax
	add di,2
	inc si
	loop mbrPrintLop

	mov eax,LOADER_START_SECTOR
	mov cx,4
	mov bx,0x900
	call loadKernalLoader
	jmp LOADER_BASE_ADDR
	
	;=================================================================
	;以下程序的功能是将位于第二扇区的内核加载器加载到内存0x900开始的地方
	;参数：
	;	eax:LBA逻辑扇区地址
	;	cx: 操作的扇区数目，
	;	bx: 加载到内存中的起始地址，即0x900
	;=================================================================
loadKernalLoader:
	mov esi,eax	;保护相关参数
	mov di,cx

	;第一步：设置要操作的扇区数
	mov dx,0x1f2
	mov ax,cx
	out dx,al

	;第二步：写入LBA的地址到各个相关的寄存器
	;写入到 LBA low
	mov dx,0x1f3
	mov eax,esi
	out dx,al

	;写入到 LBA mid
	mov cx,8
	shr eax,cl
	mov dx,0x1f4
	out dx,al

	;写入到 LBA high
	shr eax,cl
	mov dx,0x1f5
	out dx,al

	;写入到device的低四位
	shr eax,cl
	and al,0x0f		;这里清空高4位
	or al,0xe0		;设置高4位，为LBA寻址模式
	mov dx,0x1f6
	out dx,al

	;第三步：向command寄存器写入操作命令
	mov al,0x20
	mov dx,0x1f7
	out dx,al

	;第四步：读取status寄存器判断硬盘工作是否完成
.notready:
	mov dx,0x1f7
	in al,dx
	and al,0x88
	cmp al,0x08
	jne .notready

	;第五步：开始读取数据，并将数据加载到内存0x900处
	mov cx,di
	mov ax,cx
	mov dx,256
	mul dx		;这里求出总共需要读取多少次，计算公式为:操作扇区数×512/2
	mov cx,ax
	mov dx,0x1f0
	mov ax,0
	mov es,ax
	mov di,0x900
.readData:
	in ax,dx
	mov [es:di],ax
	add di,2
	loop .readData

	ret
	

	message db "2 MBR"
	times 510-($-$$) db 0
	db 0x55,0xaa
