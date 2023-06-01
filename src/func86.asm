[bits 32]

global io_hlt 	    ; 程序中包含的函数名

[section .text]
io_hlt:
    hlt
    ret