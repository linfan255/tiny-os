VEDIO_SELECTOR equ (0x0003 << 3) + 0 + 0

section .data
	print_buffer dq 0 ;32位数字可以转换成8个16进制的数字，将8个16进制数字都转换成字符，总共占8个字节，每个字符一个字节

[bits 32]
section .text
global put_char
global put_str
global put_int

;------------------ 将栈中的32位数字用16进制打印出来 ---------------
;edi：指向打印缓存区
;eax：取出来待打印的数字
;edx：待打印数字的低4位
;ebp：函数调用必然用到的基础格式
;ecx：循环用
;-------------------------------------------------------------------
put_int:
	pushad
	mov ebp,esp

	xor edi,edi
	xor ecx,ecx
	xor eax,eax

	mov edi,7
	mov ecx,8		;每次取出4位，32位数字总共要取8次
	mov eax,[ebp + 36]
.transform:			;转化，同时存到print_buffer中去
	mov edx,eax
	and edx,0x0000000f
	cmp edx,9
	jna .less9

	sub edx,10
	add edx,'A'
	jmp .transform_end

.less9:
	add edx,'0'
.transform_end:
	mov [print_buffer + edi],dl
	dec edi
	shr eax,4
	loop .transform

	xor edi,edi
	xor eax,eax

.clear_prefix:				;去除前面的‘0’，直到第一个非‘0’的字节位置，如果到达了最后一个字节就跳出（说明整个数字即为）
	mov al,[print_buffer + edi]
	cmp al,'0'
	jne .clear_prefix_end
	cmp edi,7
	je .clear_prefix_end
	inc edi
	jmp .clear_prefix

.clear_prefix_end:
.print_int:
	cmp edi,8
	je .put_int_end
	
	xor eax,eax
	mov al,[print_buffer + edi]	
	push eax
	call put_char
	add esp,4
	inc edi
	loop .print_int

.put_int_end:
	popad
	ret


;-------------- 将一串字符串写入光标处 ----------------
;栈中存放着/0结尾的字符串的起始地址
;-----------------------------------------------------
put_str:
	push ebx
	push eax
	push ebp
	mov ebp,esp

	mov ebx,[ebp + 16]
.puts_lp:
	xor eax,eax
	mov al,[ebx]
	cmp al,0
	je .put_str_end
	push eax
	call put_char
	add esp,4
	inc ebx
	jmp .puts_lp

.put_str_end:
	mov esp,ebp
	pop ebp
	pop eax
	pop ebx
	ret

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
	

