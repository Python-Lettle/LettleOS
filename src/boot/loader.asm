org 0x100

    jmp START
    nop

; Loader 栈底
StackBase   equ 0x100

START:
    ; 寄存器复位
    mov ax, cs
    mov ds, ax
    mov ss, ax
    mov sp, StackBase

    ; 显示 "Hello Loader!"
    mov dh, 0               ; "Hello Loader!"
    call DispStr            ; 显示字符串

    jmp $

; ==================================================
LoaderFileName  db  "LOADER  BIN",  0   ; LOADER.BIN文件名
; db 定义一个字节  dw 字word  dd 是双字double word
MessageLength   equ 13
Message:        db  "Hello Loader!"

; ==================================================
DispStr:
    mov ax, MessageLength
    mul dh
    add ax, Message

    ; ES:BP = 串地址
    mov bp, ax
    mov ax, ds
    mov es, ax

    mov cx, MessageLength   ; CX = 串长度
    mov ax, 01301h          ; AH = 13,  AL = 01h
    mov bx, 0007h           ; 页号为0(BH=0) 黑底白字(BL=07h)
    mov dl, 0               ; 
    int 10h
    ret

;================================================================================================
; 函数名: ReadSector
; 引用 TINIX 的读取扇区函数
;----------------------------------------------------------------------------
; 作用:
;	从序号(Directory Entry 中的 Sector 号)为 ax 的的 Sector 开始, 将 cl 个 Sector 读入 es:bx 中
ReadSector:
	; -----------------------------------------------------------------------
	; 怎样由扇区号求扇区在磁盘中的位置 (扇区号 -> 柱面号, 起始扇区, 磁头号)
	; -----------------------------------------------------------------------
	; 设扇区号为 x
	;                          ┌ 柱面号 = y >> 1
	;       x           ┌ 商 y ┤
	; -------------- => ┤      └ 磁头号 = y & 1
	;  每磁道扇区数       │
	;                   └ 余 z => 起始扇区号 = z + 1
	push	bp
	mov	bp, sp
	sub	esp, 2				; 辟出两个字节的堆栈区域保存要读的扇区数: byte [bp-2]

	mov	byte [bp-2], cl
	push	bx				; 保存 bx
	mov	bl, [BPB_SecPerTrk]	; bl: 除数
	div	bl					; y 在 al 中, z 在 ah 中
	inc	ah					; z ++
	mov	cl, ah				; cl <- 起始扇区号
	mov	dh, al				; dh <- y
	shr	al, 1				; y >> 1 (其实是 y/BPB_NumHeads, 这里BPB_NumHeads=2)
	mov	ch, al				; ch <- 柱面号
	and	dh, 1				; dh & 1 = 磁头号
	pop	bx					; 恢复 bx
	; 至此, "柱面号, 起始扇区, 磁头号" 全部得到 ^^^^^^^^^^^^^^^^^^^^^^^^
	mov	dl, [BS_DrvNum]		; 驱动器号 (0 表示 A 盘)
.GoOnReading:
	mov	ah, 2				; 读
	mov	al, byte [bp-2]		; 读 al 个扇区
	int	13h
	jc	.GoOnReading		; 如果读取错误 CF 会被置为 1, 这时就不停地读, 直到正确为止

	add	esp, 2
	pop	bp

	ret
