; 有关BOOT_INFO
CYLS EQU 0x0ff0 			; 设定启动区
LEDS EQU 0x0ff1
VMODE EQU 0x0ff2 			; 关于颜色数目的信息。颜色的位数。
SCRNX EQU 0x0ff4 			; 分辨率的X（screen x）
SCRNY EQU 0x0ff6 			; 分辨率的Y（screen y）
VRAM EQU 0x0ff8 			; 图像缓冲区的开始地址

    ; 显示彩色
    ;mov al, 0x13	; VGA显卡， 320*200*8位彩色
                    ; ​0x03: 16色字符模式，80 × 25
                    ; 0x12: VGA 图形模式，640 × 480 × 4位彩色模式，独特的4面 存储模式
                    ; ​0x13: VGA 图形模式，320 × 200 × 8位彩色模式，调色板模式
                    ; 0x6a: 扩展VGA 图形模式，800 × 600 × 4位彩色模式，独特的 4面存储模式（有的显卡不支持这个模式）
	;mov ah, 0x00   ; AH=0 设置显示方式
	;int 0x10
    mov byte [VMODE],8 	; 记录画面模式
    mov word [SCRNX],320
    mov word [SCRNY],200
    mov dword [VRAM],0x000a0000