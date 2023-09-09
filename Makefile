#----------------------------------------
# 工具链
#----------------------------------------
GCC = gcc
GPP = g++
QEMU = qemu-system-i386
ASM = nasm

#----------------------------------------
# 目录结构
#----------------------------------------
s = src
sb = $(s)/boot
sk = $(s)/kernel

t = target
tb = $t/boot
tk = $t/kernel

i = include

#----------------------------------------
# 编译选项
#----------------------------------------
# LettleOS 的内存装载点
# 这个值必须存在且相等在文件"load.inc"中的 'KernelEntryPointPhyAddr'！
ENTRYPOINT = 0x1000

ASMFlagsOfBoot	= -I src/boot/include/
ASMFlagsOfKernel= -f elf -I $(sk)/
ASMFlagsOfSysCall = -f elf
CFlags			= -I$i -c -fno-builtin -Wall -m32
LDFlags			= -m elf_i386 -Ttext $(ENTRYPOINT) -Map kernel.map
DASMFlags		= -D
ARFLAGS		    = rcs
#----------------------------------------
# 镜像相关
#----------------------------------------
IMG_NAME=LettleOS.img
# 镜像挂载点，自指定，必须存在于自己的计算机上，如果没有请自行创建一下
FloppyMountPoint= /mnt/LettleOS

BootBin = $(tb)/boot.bin $(tb)/loader.bin
KernelObjs = $(tk)/main.o $(tk)/kernel.o $(tk)/kernel_386lib.o

all: image

run: all
	$(QEMU) -no-reboot -parallel stdio -fda $(IMG_NAME) -serial null

image: $(BootBin) $(tk)/kernel.bin
	dd if=/dev/zero of=$(IMG_NAME) bs=512 count=2880
	dd if=$(tb)/boot.bin of=$(IMG_NAME) bs=512 count=1 conv=notrunc
	sudo mount -o loop $(IMG_NAME) $(FloppyMountPoint)
	sudo cp -fv $(tb)/loader.bin $(FloppyMountPoint)
	sudo cp -fv $(tk)/kernel.bin $(FloppyMountPoint)
	sudo umount $(FloppyMountPoint)

clean:
	rm -rf $(IMG_NAME) $(BootBin) $(KernelObjs) $(tk)/kernel.bin

$(tb)/boot.bin: $(sb)/boot.asm
	mkdir -p $(tb)
	$(ASM) $(ASMFlagsOfBoot) $< -o $@

$(tb)/loader.bin: $(sb)/loader.asm
	mkdir -p $(tb)
	$(ASM) $(ASMFlagsOfBoot) $< -o $@

$(tk)/kernel.bin: $(KernelObjs)
	$(LD) $(LDFlags) -o $(tk)/kernel.bin $^

$(tk)/main.o: $(sk)/main.c
	$(GCC) $(CFlags) -o $@ $<

$(tk)/kernel.o: $(sk)/kernel.asm
	$(ASM) $(ASMFlagsOfKernel) $< -o $@

$(tk)/kernel_386lib.o: $(sk)/kernel_386lib.asm
	$(ASM) $(ASMFlagsOfKernel) $< -o $@