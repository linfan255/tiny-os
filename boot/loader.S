%include "boot.inc"
section loader vstart=LOADER_BASE_ADDR
	mov cx,8
	mov ax,0xb800
	mov gs,ax
	mov di,0

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
	jmp $

	msg db "2 loader"
