VEDIO_SELECTOR equ (0x0003 << 3) + 0 + 0

[bits 32]
section .text
global put_char
;-------------- 把参数写入屏幕光标处 -----------------
put_char:
	pushad
	mov ebp,esp
	mov ax,VEDIO_SELECTOR
	mov gs,ax 

	;获取光标位置
	mov dx,0x3d4
	mov al,0x0e
	out dx,al
	mov dx,0x3d5
	in al,dx		;光标高8位

	mov ah,al

	mov dx,0x3d4
	mov al,0x0f
	out dx,al
	mov dx,0x3d5
	in al,dx

	mov bx,ax		;光标位置存放在bx寄存器
	mov ecx,[ebp + 36] ;获得要打印的字符,存放在dx中

	cmp cl,0x0d		;是回车键
	je .return_key
	cmp cl,0x8
	je .back_space	;是退格键
	cmp cl,0x0a
	je .line_end	;是换行符

	;如果不是上面那三个就直接打印出来
	mov ah,0x07
	mov al,cl
	shl bx,1
	mov [gs:bx],ax
	shr bx,1
	inc bx
	cmp bx,2000
	jl .setcursor
	jmp .roll_screen	;每次打印完一个字符判断是否需要换行

	;处理回车键的动作，分为两部分
	;1:置换到行首
	;2:加上160
.return_key:
.line_end:	;回车键和换行符的动作一样
	xor dx,dx
	mov ax,bx
	mov cx,80
	div cx
	sub bx,dx ;减去余数，置换到行首
	add bx,80
	cmp bx,2000
	jl .setcursor
	jmp .roll_screen

	;处理退格键的动作
	;1、将光标位置减去1  2、将原位置用空格补上
.back_space:
	dec bx
	shl bx,1
	mov ax,0x0720
	mov [gs:bx],ax
	shr bx,1
	jmp .setcursor

.roll_screen:
	cld
	mov esi,0xb80a0
	mov edi,0xb8000
	mov ecx,960
	rep movsd		;将从第二行到最后一行的内容往上移动一行

	;将最后一行的内容清空
	mov ax,0x0720
	mov ebx,3840
	mov cx,80
.clear_last_line:
	mov [gs:ebx],ax
	add ebx,2
	loop .clear_last_line
	mov bx,1920		;将光标置于最后一行行首
	jmp .setcursor

.setcursor:
	mov dx,0x3d4
	mov al,0x0e
	out dx,al
	mov dx,0x3d5
	mov al,bh
	out dx,al	;写入光标位置的高8位

	mov dx,0x3d4
	mov al,0x0f
	out dx,al
	mov dx,0x3d5
	mov al,bl
	out dx,al	;写入光标位置的低8位

	mov esp,ebp
	popad
	ret
