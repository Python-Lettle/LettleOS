;============================================================================
;   导入和导出
;----------------------------------------------------------------------------
; 导入变量
extern display_position
; 导出函数
global printf
;============================================================================
; 函数原型：void printf(char* str)
;----------------------------------------------------------------------------
printf:
    push esi
    push edi
    mov esi, [esp + 4 * 3]      ; 得到字符串地址
    mov edi, [display_position]   ; 得到显示位置
    mov ah, 0xf                 ; 黑底白字
.syn_end:
    lodsb                       ; ds:esi -> al, esi++
    test al, al
    jz .PrintEnd                ; 遇到了0，结束打印
    cmp al, 10
    je .syn_enter
    ; 如果不是0，也不是'\n'，那么我们认为它是一个可打印的普通字符
    mov [gs:edi], ax
    add edi, 2                  ; 指向下一列
    jmp .syn_end
.syn_enter: ; 处理换行符'\n'
    push eax
    mov eax, edi                ; eax = 显示位置
    mov bl, 160
    div bl                      ; 显示位置 / 160，商eax就是当前所在行数
    inc eax                     ; 行数++
    mov bl, 160
    mul bl                      ; 行数 * 160，得出这行的显示位置
    mov edi, eax                ; edi = 新的显示位置
    pop eax
    jmp .syn_end
.PrintEnd:
    mov dword [display_position], edi ; 更新显示位置
    pop edi
    pop esi
    ret
