; ==================================================
org 0x7c00      ; 程序开始处
; ==================================================

; BPB(BIOS Parameter Block) 中需要的跳转结构
; BS_jmpBoot: 一个短跳转指令, 长度3
    jmp LABEL_START
    nop

    BS_OEMName	DB '-Lettle-'	; OEM String, 必须 8 个字节

    BPB_BytsPerSec	DW 512		; 每扇区字节数
    BPB_SecPerClus	DB 1		; 每簇多少扇区
    BPB_RsvdSecCnt	DW 1		; Boot 记录占用多少扇区
    BPB_NumFATs	DB 2		    ; 共有多少 FAT 表
    BPB_RootEntCnt	DW 224		; 根目录文件数最大值
    BPB_TotSec16	DW 2880		; 逻辑扇区总数
    BPB_Media	DB 0xF0		    ; 媒体描述符
    BPB_FATSz16	DW 9		    ; 每FAT扇区数
    BPB_SecPerTrk	DW 18		; 每磁道扇区数
    BPB_NumHeads	DW 2		; 磁头数(面数)
    BPB_HiddSec	DD 0		    ; 隐藏扇区数
    BPB_TotSec32	DD 0		; 如果 wTotalSectorCount 是 0 由这个值记录扇区数

    BS_DrvNum	DB 0		    ; 中断 13 的驱动器号
    BS_Reserved1	DB 0		; 未使用
    BS_BootSig	DB 29h		    ; 扩展引导标记 (29h)
    BS_VolID	DD 0		    ; 卷序列号
    BS_VolLab	DB '_Lettle_OS_'    ; 卷标, 必须 11 个字节
    BS_FileSysType	DB 'FAT12   '	; 文件系统类型, 必须 8个字节  


; ==================================================
StackBase   equ 0x7c00  ; 栈顶
; ==================================================
; 程序开始入口
; --------------------------------------------------
LABEL_START:
    mov ax, cs
    mov ds, ax
    mov ss, ax
    mov sp, StackBase

    ; 清理屏幕输出
    mov ax, 0x0600          ; AH = 6, AL = 0h
    mov bx, 0x0700          ; 黑底白字 (BL = 07h)
    mov cx, 0               ; 左上角: (0,0)
    mov dx, 0x0184f         ; 右下角: (80,50)
    int 0x10                ; int 10h

    ; 显示 "Booting....."
    mov dh, 0               ; "Booting....."
    call DispStr            ; 显示字符串

    jmp $

; ==================================================
LoaderFileName  db  "LOADER  BIN",  0   ; LOADER.BIN文件名
; db 定义一个字节  dw 字word  dd 是双字double word
MessageLength   equ 12
BootMessage:    db  "Booting....."

; ==================================================
DispStr:
    mov ax, MessageLength
    mul dh
    add ax, BootMessage

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

; ==================================================
; times n,m     n: 重复定义多少次 m: 定义的数据
times 510-($-$$)    db  0
dw 0xAA55       ; 引导扇区标志
; ==================================================