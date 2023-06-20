FD = LOS.img

KERNEL_ENTRY_POINT_PHY_ADDR = 0x1000

# 架构
arch = 80386

# 源码目录结构
s   = src
aa  = arch/$(arch)
sb  = $s/$(aa)/boot
sbi = $(sb)/include
sk  = $s/kernel
sl  = $s/lib

# 输出目录结构
t  = target
tb = $t/boot
tk = $t/kernel

# 库文件目录结构
i = include

# 各种编译用程序
ASM = nasm
CC  = x86_64-elf-gcc
LD  = x86_64-elf-ld

ASMFlagsOfBoot   = -I $(sbi)
ASMFlagsOfKernel = -f elf -I $(sk)
CFlags			 = -c -I $i -fno-builtin -Wall -m32
LDFlags         = -m elf_i386 -Ttext $(KERNEL_ENTRY_POINT_PHY_ADDR)

LettleOSBoot   = $(tb)/boot.bin $(tb)/loader.bin
LettleOSKernel = $(tk)/kernel.bin

KernelObjs = $(tk)/kernel.o $(tk)/kernel_func.o $(tk)/main.o

Objs = $(KernelObjs)

.PHONY: nop all write run clean

nop:
	@echo "all          编译所有文件"
	@echo "image        创建image镜像文件"
	@echo "clean        清理所有编译文件"
	@echo "run          用qemu启动虚拟机"

all: $(LettleOSBoot) $(LettleOSKernel)

image: $(tb)/boot.bin $(tb)/loader.bin
	dd if=/dev/zero of=$(FD) bs=512 count=2880
	dd if=$(tb)/boot.bin of=$(FD) bs=512 count=1 conv=notrunc

run:
	@qemu-system-i386 -drive file=$(FD),if=floppy

clean:
	rm -f $(tb)/* $(tk)/* $(FD)

#==============================================================================
# Boot
#==============================================================================
# Boot程序生成规则
$(tb)/boot.bin:	$(sbi)/fat12hdr.inc
$(tb)/boot.bin: $(sb)/boot.asm
	$(ASM) $(ASMFlagsOfBoot) -o $@ $<

# Loader程序生成规则
$(tb)/loader.bin: $(sbi)/fat12hdr.inc $(sbi)/load.inc
$(tb)/loader.bin: $(sb)/loader.asm
	$(ASM) $(ASMFlagsOfBoot) -o $@ $<

#==============================================================================
# Kernel
#==============================================================================
# Kernel生成规则
#------------------------------------------------------------------------------
$(LettleOSKernel): $(Objs)
	$(LD) $(LDFlags) -o $(LettleOSKernel) $^

#------------------------------------------------------------------------------
# 中间obj生成
#------------------------------------------------------------------------------
$(tk)/kernel.o: $(sb)/kernel.asm
	$(ASM) $(ASMFlagsOfKernel) -o $@ $<

$(tk)/main.o: $(sk)/main.c
	$(CC) $(CFlags) -o $@ $<

$(tk)/kernel_func.o: $(sb)/kernel_func.asm
	$(ASM) $(ASMFlagsOfKernel) -o $@ $<




