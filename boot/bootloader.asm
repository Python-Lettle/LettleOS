; ==================================================================
; Bootloader
; ==================================================================
org 07c00h                         ; Boot状态 BIOS将会把 Bootloader 加载到 0:7c00处运行
[BITS 16]                           
align 16

; 有关BOOT_INFO
CYLS EQU 0x0ff0 			; 设定启动区
LEDS EQU 0x0ff1
VMODE EQU 0x0ff2 			; 关于颜色数目的信息。颜色的位数。
SCRNX EQU 0x0ff4 			; 分辨率的X（screen x）
SCRNY EQU 0x0ff6 			; 分辨率的Y（screen y）
VRAM EQU 0x0ff8 			; 图像缓冲区的开始地址
BaseOfStack	equ 0x100       ; 基栈
; 16位实模式代码段
BOOT_START:
    ; 寄存器复位
    mov	ax, cs
	mov	ds, ax
	mov	es, ax
	mov	ss, ax
	mov	sp, BaseOfStack

    ; 显示彩色
    mov al, 0x13	; VGA显卡， 320*200*8位彩色
                    ; ​0x03: 16色字符模式，80 × 25
                    ; 0x12: VGA 图形模式，640 × 480 × 4位彩色模式，独特的4面 存储模式
                    ; ​0x13: VGA 图形模式，320 × 200 × 8位彩色模式，调色板模式
                    ; 0x6a: 扩展VGA 图形模式，800 × 600 × 4位彩色模式，独特的 4面存储模式（有的显卡不支持这个模式）
	mov ah, 0x00    ; AH=0 设置显示方式
	int 0x10
    mov byte [VMODE],8 	; 记录画面模式
    mov word [SCRNX],320
    mov word [SCRNY],200
    mov dword [VRAM],0x000a0000

    ;------------------------------------------------------------------
    ; 进入32位保护模式
    ;------------------------------------------------------------------
    ; 1 首先，进入保护模式必须有 GDT 全局描述符表，我们加载 gdtr（gdt地址指针）
    lgdt	[gdt_descriptor]

    ; 2 由于保护模式中断处理的方式和实模式不一样，所以我们需要先关闭中断，否则会引发错误
    cli

    ; 3 打开地址线A20，不打开也可以进入保护模式，但内存寻址能力受限（1MB）
    in al, 92h              ; 从92h号端口读入一个字节
    or al, 00000010b
    out 92h, al

    ; 4 进入16位保护模式，设置cr0的第0位：PE（保护模式标志）为1
    mov eax, cr0
    or 	eax, 1
    mov cr0, eax

    ; 5 真正进32位入保护模式！前面的4步已经进入了保护模式
    ; 	现在只需要跳入到一个32位代码段就可以真正进入32位保护模式了！
    ; jmp dword SelectorCode:LOADER_PHY_ADDR + PM_32_START

    
fin:
    HLT
    JMP fin


; 内存检查结果缓冲区，用于存放没存检查的ARDS结构，256字节是为了对齐32位，256/20=12.8
; ，所以这个缓冲区可以存放12个ARDS。
_MemChkBuf:          times 256 db 0                                          

;-----------------------------------
;   GDT
;-----------------------------------
gdt_start:
    ; 空 descriptor, 为了让CPU识别
    dd 0
    dd 0

    ; Code segment descriptor
    dw 0xFFFF       ; Limit (bits 0-15)
    dw 0x0          ; Base (bits 0-15)
    db 0x0          ; Base (bits 16-23)
    db 10011010b    ; Access byte (present, ring 0, code segment, execute/read)
    db 11001111b    ; Flags and limit (bits 16-19)

    ; Data segment descriptor
    dw 0xFFFF ; Limit (bits 0-15)
    dw 0x0 ; Base (bits 0-15)
    db 0x0 ; Base (bits 16-23)
    db 10010010b ; Access byte (present, ring 0, data segment, read/write)
    db 11001111b ; Flags and limit (bits 16-19)

gdt_end:
gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start

;============================================================================
; times n m        n：重复多少次   m：重复的代码
times 510-($-$$)   db    0  ; 填充剩下的空间，使生成的二进制代码恰好为512字节
dw  0xaa55                  ; 可引导扇区结束标志，必须是55aa，不然 BIOS 无法识别
;============================================================================
