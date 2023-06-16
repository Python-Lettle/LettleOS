;================================================================================================
; 16 位代码段
; 引导程序,寻找并加载Loader
;================================================================================================
; org  07c00h			; Boot 状态, Bios 将把 Boot Sector 加载到 0:7C00 处并开始执行
[bits 16]
align 16
; LOADER加载到的段地址
LOADER_SEG      equ 0x9000
; LOADER加载到的偏移地址
LOADER_OFFSET   equ 0x100

; kernel code segment selector
PROT_MODE_CSEG  equ       0x8
; kernel data segment selector
PROT_MODE_DSEG  equ       0x10
; protected mode enable flag
CR0_PE_ON       equ       0x1

;================================================================================================
BaseOfStack		equ	07c00h	; Boot状态下堆栈基地址(栈底, 从这个位置向低地址生长)
;================================================================================================
	jmp short BOOT_START		; 跳转到程序开始处
	nop							; 这个 nop 不可少
    ; 导入FAT12头以及相关常量信息
    ; %include "fat12hdr.inc"
;================================================================================================
; 程序入口
;----------------------------------------------------------------------------
[global BOOT_START]
BOOT_START:
    ; 寄存器复位(清零)
    xor ax, ax          ; ax置零
	mov	ds, ax
	mov	es, ax
	mov	ss, ax
	mov	sp, BaseOfStack

    ; 清屏,清理BIOS的输出
    mov	ax, 0x0600		; AH = 6,  AL = 0h
    mov	bx, 0x0700		; 黑底白字(BL = 07h)
    mov	cx, 0			; 左上角: (0, 0)
    mov	dx, 0x0184f		; 右下角: (80, 50)
    int	0x10		    ; int 10h

    ; 软驱复位
    xor ah, ah          ; xor:异或，ah = 0
    xor dl, dl          ; dl = 0
    int 0x13
IN_PROTECT_MODE:
    ;----------------------------------------------------------------------------
    ; 进入保护模式必须有 GDT 全局描述符表, 加载 gdtr
    ; lgdt	[gdt_descriptor]

    ; 此时中断向量表未建立(32位保护模式下)
	; 禁止中断，防止出错
    cli
SET_A20:
    ; 打开地址线A20，不打开也可以进入保护模式，但内存寻址能力受限（1MB）
    in al, 92h          ; 南桥芯片的端口
    or al, 00000010b
    out 92h, al
JUMP_PM:
    ; 设置cr0的第0位：PE（保护模式标志）为1
    mov eax, cr0
    or 	eax, 1
    mov cr0, eax

    ; 5 真正进32位入保护模式！前面的4步已经进入了保护模式
    ; 	现在只需要跳入到一个32位代码段就可以真正进入32位保护模式了！
    jmp dword SelectorCode

; ------------------------------------------------------------------
; Define the Global Descriptor Table (GDT) for Bootstrap
; ------------------------------------------------------------------
gdt_start:
    ; Null descriptor
    dd 0
    dd 0
gdt_code_seg:
    ; Code segment descriptor
    dw 0xFFFF       ; Limit (bits 0-15)
    dw 0x0          ; Base (bits 0-15)
    db 0x0          ; Base (bits 16-23)
    db 10011010b    ; Access byte (present, ring 0, code segment, execute/read)
    db 11001111b    ; Flags and limit (bits 16-19)
gdt_data_seg:
    ; Data segment descriptor
    dw 0xFFFF       ; Limit (bits 0-15)
    dw 0x0          ; Base (bits 0-15)
    db 0x0          ; Base (bits 16-23)
    db 10010010b    ; Access byte (present, ring 0, data segment, read/write)
    db 11001111b    ; Flags and limit (bits 16-19)
gdt_end:

; GDT指针
gdt_descriptor:
    dw gdt_end - gdt_start - 1                                  ; GDT 段界限
    dd gdt_start                                                ; GDT 基址
; GDT选择子 ------------------------------------------------------------------
[global SelectorCode]
[global SelectorData]
SelectorCode        equ gdt_code_seg - gdt_start             ; 代码段选择子
SelectorData        equ gdt_data_seg - gdt_start             ; 数据段选择子

;================================================================================================
; 32 位代码段
; 此处已经进入保护模式
;================================================================================================
[bits 32]
align 32

[extern _kernel_main]

PM_32_START:
    ; 设置保护模式数据段寄存器
    mov ax, SelectorData
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    ; 设置栈指针, 栈区域为0--0x7c00
    mov ebp, 0x0
    mov esp, 0x7c00
    ; 跳入C语言
    call _kernel_main

spin:
    hlt
    jmp spin

;============================================================================
; times n m        n：重复多少次   m：重复的代码
times 510-($-$$)   db    0  ; 填充剩下的空间，使生成的二进制代码恰好为512字节
dw  0xaa55                  ; 可引导扇区结束标志，必须是55aa，不然 BIOS 无法识别
;============================================================================