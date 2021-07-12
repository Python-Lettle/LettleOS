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
CC  = gcc
LD  = ld

ASMFlagsOfBoot   = -I $(sbi)
ASMFlagsOfKernel = -f elf -I $(sk)
CFlags			 = -c -I $i -fno-builtin -Wall -m32
LDFlags         = -m elf_i386 -Ttext $(KERNEL_ENTRY_POINT_PHY_ADDR)

LettleOSBoot   = $(tb)/boot.bin $(tb)/loader.bin
LettleOSKernel = $(tk)/kernel.bin

KernelObjs = $(tk)/kernel.o $(tk)/main.o

.PHONY: nop all write run clean

nop:
	@echo "all          编译所有文件"
	@echo "write        写入image镜像文件"
	@echo "clean        清理所有编译文件"
	@echo "run          用qemu启动虚拟机"

all: $(LettleOSBoot)

write: $(FD) $(tb)/boot.bin
	dd if=$(tb)/boot.bin of=$(FD) bs=512 count=1 conv=notrunc

run: $(FD)
	@qemu-system-i386 -drive file=$(FD),if=floppy
	@echo "你还可以使用Vbox等虚拟机挂载LOS.img软盘，即可开始运行！"

clean:
	rm -f $(tb)/*
	rm -f $(tk)/*

# 软盘创建规则
$(FD):
	dd if=/dev/zero of=$(FD) bs=512 count=2880

# Boot程序生成规则
$(tb)/boot.bin:	$(sbi)/fat12hdr.inc
$(tb)/boot.bin: $(sb)/boot.asm
	$(ASM) $(ASMFlagsOfBoot) -o $@ $<

# Loader程序生成规则
$(tb)/loader.bin: $(sbi)/fat12hdr.inc $(sbi)/load.inc
$(tb)/loader.bin: $(sb)/loader.asm
	$(ASM) $(ASMFlagsOfBoot) -o $@ $<




