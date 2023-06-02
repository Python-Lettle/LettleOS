[bits 32]

; 程序中包含的函数名
global io_hlt, write_mem8 	    

[section .text]
io_hlt:
    hlt
    ret

write_mem8: 	; void write_mem8(int addr, int data);
    mov eax,[esp+4]	 	; [ESP + 4]中存放的是地址，将其读入ECX
    mov al,[esp+8] 		; [ESP + 8]中存放的是数据，将其读入AL
    mov [ecx],al
    ret

