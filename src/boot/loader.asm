org 0x100
    jmp START

%include "load.inc"         ; 挂载点相关定义
%include "fat12hdr.inc"     ; 导入FAT12头以及相关常量信息来加载内核文件

BaseOfStack		equ	0x100	; 调试状态下堆栈基地址(栈底, 从这个位置向低地址生长)

;============================================================================
; 16位实模式代码段
;----------------------------------------------------------------------------
START:
    ; 寄存器复位
    mov	ax, cs
    mov	ds, ax
    mov	es, ax
    mov	ss, ax
    mov	sp, BaseOfStack

    ; 显示字符串 "Hello Loader!"
    mov	dh, 0
    call DispStr		; 显示字符串

    mov ebx, 0          ; ebx = 得到后续的内存信息, 初始化必须为0, 将获取第一个ADRS
    mov di, _MemChkBuf  ; es:di -> 指向准备写入ADRS的缓冲区地址
MemChkLoop:
    mov eax, 0x0000e820 ; 
    mov ecx, 20
    mov edx, 0x0534d4150; "SMAP"
    int 0x15            ; 得到ADRS
    jc MemChkFail

    ; CF = 0, 检查并获取成功
    add di, 20          ; di += 20, es:di 指向缓冲区准备放入下一个ADRS的地址
    inc dword [_ddMCRCount] ; ADRS数量++
    cmp ebx, 0
    je  MemChkFinish        ; ebx == 0, 表示已经拿到最后一个ADRS, 完成检查
    ; ebx != 0, 表示还没拿到最后一个, 继续
    jmp MemChkLoop

MemChkFail:
    mov dword [_ddMCRCount], 0  ; 检查失败, ADRS数量设置为0
    mov dh, 1
    call DispStr
    jmp io_hlt

MemChkFinish:
    ; 操作软盘前 将软驱复位
    xor ah, ah
    xor dl, dl              ; dl = 0 软盘A
    int 0x13

    ; 在软盘A中寻找文件 kernel.bin
    mov word [wSector], SectorNoOfRootDirectory ; 读取软盘根目录扇区号
SEARCH_FILE_IN_ROOT_DIR_BEGIN:
    cmp word [wRootDirSizeLoop], 0
    jz NO_FILE                              ; jz 小于等于 0 即读完了整个根目录都没找到
    dec word [wRootDirSizeLoop]             ; wRootDirSizeLoop--

    ; 读取扇区
    mov ax, KERNEL_SEG
    mov es, ax
    mov bx, KERNEL_OFFSET
    mov ax, [wSector]                       ; es:bx
    mov cl, 1
    call ReadSector
    
    ; 初始化
    mov si, KernelFileName                  ; ds:si -> Kernel 文件名
    mov di, KERNEL_OFFSET                   ; ex:di -> KERNEL_SEG:KERNEL_OFFSET -> 加载到内存中的扇区数据
    cld                                     ; 字符串比较方向, si di 方向向右  (std向后增长)

    ; 开始在扇区中寻找文件, 比较文件名
    mov dx, 16                              ; 一个扇区有512字节, FAT目录项是32位, 512/32=16  一个扇区有16个目录项
SEARCH_FOR_FILE:
    cmp dx, 0
    jz NEXT_SECTOR_IN_ROOT_DIR              ; 读完整个扇区, 依旧没找到, 准备加载下一个扇区
    dec dx                                  ; dx--
    ; 应该开始比较目录项中的文件名了
    mov cx, 11
CMP_FILENAME:
    cmp cx, 0
    jz FILENAME_FOUND                       ; cx = 0, 整个文件名里的字符都匹配上了
    dec cx                                  ; cx--
    lodsb                                   ; load string byte: ds:si 加载一个字节到 al, si++
    cmp al, byte [es:di]                    ; 比较字符
    je GO_ON                                ; 字符相同，准备比较下一个
    jmp DIFFERENT                           ; 只要有一个字符不相同, 就表示本目录项不是要寻找的目录项

GO_ON:
    inc di
    jmp CMP_FILENAME

DIFFERENT:
    ; 文件名长度为11, 让底4位变成0
    ; di &= f0, 11111111 11110000, 是为了让它指向本目录项条目的开始
    and di, 0xfff0                          
    add di, 32                              ; di += 32, 让di指向下一个目录项
    mov si, KernelFileName
    jmp SEARCH_FOR_FILE                     ; 重新开始在下一个目录项中查找文件并比较

NEXT_SECTOR_IN_ROOT_DIR:
    add word [wSector], 1                   ; 准备开始读下一个扇区
    jmp SEARCH_FILE_IN_ROOT_DIR_BEGIN

NO_FILE:
    mov dh, 2                               ; 打印 "No Kernel !!!"
    call DispStr
    jmp io_hlt

FILENAME_FOUND:
    push es
    mov dh, 1
    call DispStr
    pop es

    ; 准备参数, 开始读取文件数据扇区
    mov ax, RootDirSectors                  ; ax = 根目录占用的扇区数量
    and di, 0xfff0                          ; 
    add di, 0x1a                            ; FAT 目录项第0x1a处偏移是文件数据所在的第一个簇号
    mov cx, word [es:di]                    ; cx = 文件数据所在的第一个簇号
    push cx                                 ; 保存
    ; 通过簇号计算它真正扇区号
    add cx, RootDirSectors
    add cx, DeltaSectorNo                   ; 簇号 + 根目录占用空间 + 文件开始扇区号 = 
    mov ax, KERNEL_SEG
    mov es, ax                              ; es <- KERNEL_SEG
    mov bx, KERNEL_OFFSET                   ; bx <- KERNEL_OFFSET
    mov ax, cx                              ; ax = 文件数据的第一个扇区
LOADING_FILE:
    ; 我们每读取一个数据扇区，就在"Loading..."之后打印一个'*', 形成动态加载
    ; 0x10中断, 0xE功能 --> 在光标处打印一个字符
    push ax
    push bx
    mov ah, 0xe
    mov al, '*'
    mov bl, 0x7
    int 0x10
    pop bx
    pop ax

    mov cl, 1                               ; 读一个
    call ReadSector                         ; 读取

    pop ax                                  ; 取出前面保存的簇号
    call GET_FATEntry                       ; 通过簇号获得该文件的下一个FAT项的值
    cmp ax, 0xff8
    jae FILE_LOADED                         ; 加载完成
    ; FAT项的值 < 0xff8, 那么我们继续设置下一次要读取的扇区的参数
    ; 通过簇号计算它真正扇区号
    push ax                                 ; 保存簇号
    add ax, RootDirSectors
    add ax, DeltaSectorNo                   ; 簇号 + 根目录占用空间 + 文件开始扇区号 = 
    add bx, [BPB_BytsPerSec]                ; bx += 扇区字节数
    jmp LOADING_FILE

FILE_LOADED:
    mov dh, 3
    call DispStr
    
io_hlt:         ; 死循环
    hlt
    jmp io_hlt

;============================================================================
; 要显示的字符串
;----------------------------------------------------------------------------
KernelFileName		db	"KERNEL  BIN", 0	; KERNEL.BIN 文件名
; 为简化代码, 下面每个字符串的长度均为 MessageLength
MessageLength		equ	13
Message:		    db	"Hello Loader!"  ; 13字节, 不够则用空格补齐. 序号 0
                    db  "Mem Chk Fail!"
                    db  "No Kernel !!!"
                    db  "Kernel Loaded"
wRootDirSizeLoop    dw  RootDirSectors      ; 根目录占用的扇区数,在循环中逐步递减至0
wSector             dw  0                   ; 要读取的扇区号
isOdd               db  0                   ; 读取的FAT条目是奇数项还是偶数项
;============================================================================
;----------------------------------------------------------------------------
; 函数名: DispStr
;----------------------------------------------------------------------------
; 作用:
;	显示一个字符串, 函数开始时 dh 中应该是字符串序号(0-based)
DispStr:
	mov	ax, MessageLength
	mul	dh
	add	ax, Message
	mov	bp, ax			; ┓
	mov	ax, ds			; ┣ ES:BP = 串地址
	mov	es, ax			; ┛
	mov	cx, MessageLength	; CX = 串长度
	mov	ax, 01301h		; AH = 13,  AL = 01h
	mov	bx, 0007h		; 页号为0(BH = 0) 黑底白字(BL = 07h)
	mov	dl, 0
	int	10h			; int 10h
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
	;                           ┌ 柱面号 = y >> 1
	;       x           ┌ 商 y ┤
	; -------------- => ┤      └ 磁头号 = y & 1
	;  每磁道扇区数       │
	;                   └ 余 z => 起始扇区号 = z + 1
	push	bp
	mov	bp, sp
	sub	esp, 2			; 辟出两个字节的堆栈区域保存要读的扇区数: byte [bp-2]

	mov	byte [bp-2], cl
	push	bx			; 保存 bx
	mov	bl, [BPB_SecPerTrk]	; bl: 除数
	div	bl			; y 在 al 中, z 在 ah 中
	inc	ah			; z ++
	mov	cl, ah			; cl <- 起始扇区号
	mov	dh, al			; dh <- y
	shr	al, 1			; y >> 1 (其实是 y/BPB_NumHeads, 这里BPB_NumHeads=2)
	mov	ch, al			; ch <- 柱面号
	and	dh, 1			; dh & 1 = 磁头号
	pop	bx			; 恢复 bx
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

; ==================================================
; 找到簇号为 ax 在 FAT 表中的FAT项，将结果放入 ax 中
; 中间我们要加载 FAT 表的扇区到es:bx处，所以我们需要先保存es:bx
GET_FATEntry:
    push es
    push bx

    ; 在加载的段地址处开辟新的空间用于存放加载的FAT表
    push ax
    mov ax, KERNEL_SEG - KERNEL_OFFSET
    mov es, ax
    pop ax

    ; 1. 计算出簇号在FAT中的字节便宜量，计算出该簇号的奇偶性
    ; 偏移量: 簇号 * 3 / 2, 因为3个字节表示2个簇，所以字节和簇之间的比例就是3:2
    mov byte [isOdd], 0         ; isOdd = False
    mov bx, 3                   ;
    mul bx                      ; ax * bx -> dx存放高8位，ax存放低8位
    mov bx, 2
    div bx                      ; dx:ax / 2 -> ax存放商，dx存放余数
    cmp dx, 0
    je EVEN
    mov byte [isOdd], 1         ; isOdd = True

EVEN:
    ; FAT表占9个扇区, 例如：
    ; 簇号5, 5 / 512 = 0 ... 5，FAT表中0扇区中这个所在偏移是5
    ; 簇号570, 570 / 512 = 1 ... 58，FAT表中1扇区中这个所在偏移是58
    xor dx, dx
    mov bx, [BPB_BytsPerSec]    ; bx = 每扇区字节数
    div bx                      ; dx:ax / 每扇区字节数, ax(商)存放FAT项相对于FAT表的扇区号
                                ;                     dx(余数)FAT项在相对于FAT表的扇区的偏移
    push dx                     ; 保存FAT项在相对于FAT表的扇区的偏移
    mov bx, 0                   ; bx = 0, es:bx -> (KERNEL_SEG - 0x100):0
    add ax, SectorNoOfFAT1      ; 此句执行后 ax 就是 FATEntry 所在的扇区号
    mov cl, 2                   ; 读取2个扇区
    call ReadSector             ; 一次读两个为了避免边界错误问题，因为一个FAT项可能跨越两个扇区
    pop dx                      ; 恢复FAT项在相对于FAT表中的偏移
    add bx, dx                  ; bx += FAT项在相对于FAT表中的偏移, 得到FAT项在内存中的偏移地址，因为已经将扇区读到内存中
    mov ax, [es:bx]             ; ax = 簇号对应的FAT项
    cmp byte [isOdd], 1
    jne EVEN_2
    ; 奇数FAT项处理
    shr ax, 4                   ; 需要清零底四位
    jmp GET_FATEntry_OK
EVEN_2:     ; 偶数FAT项处理
    and ax, 0000111111111111b   ; 需要清零高四位
GET_FATEntry_OK:
    pop bx
    pop es
    ret

;============================================================================
; 32位数据段
;----------------------------------------------------------------------------
[section .data32]
align 32
DATA32:
;----------------------------------------------------------------------------
; 16位实模式下的数据地址符号
;----------------------------------------------------------------------------
_ddMCRCount:    dd 0        ; memory check result 检测完成的ADRS数量，为0则检查失败
_ddMemSize:     dd 0        ; 内存大小
; 地址范围描述符结构(Address Range Descriptor Structure)
_ADRS:
    _ddBaseAddrLow      dd  0       ; 基地址低32位
	_dwBaseAddrHigh:	dd	0       ; 基地址高32位
	_dwLengthLow:		dd	0       ; 内存长度(字节)低32位
	_dwLengthHigh:		dd	0       ; 内存长度(字节)高32位
	_dwType:		    dd	0       ; ADRS类型, 用于判断能否被OS使用
_MemChkBuf:	times	256	db	0       ; 内存检查结果缓冲区, 用于存放内存检查的ADRS结构，256个字节为了对齐32位
                                    ; 256 / 20 = 12.8, 这个缓冲区可以存放12个ADRS
;----------------------------------------------------------------------------
; 32位模式下的数据地址符号
;----------------------------------------------------------------------------

;============================================================================