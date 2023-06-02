;============================================================================
;   导入和导出
;----------------------------------------------------------------------------
; 导入函数
extern lettle_os                  ; 内核主函数
; 导出函数
global _start                       ; 导出_start程序开始符号，链接器需要它
;============================================================================
;   内核堆栈段
;----------------------------------------------------------------------------
[section .bss]
StackSpace:     resb 4 * 1024       ; 4KB栈空间
StackTop:
;============================================================================
;   内核代码段
;----------------------------------------------------------------------------
[section .text]
_start:     ; 内核程序入口
    ; 寄存器复位
    mov ax, ds
    mov es, ax
    mov fs, ax
    mov ss, ax              ; es = fs = ss = 内核数据段
    mov esp, StackTop       ; 栈顶
    jmp lettle_os
    jmp $