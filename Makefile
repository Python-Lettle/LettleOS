
ENTRYPOINT = 0x1000
ENRTYOFFSET = 0
# ==================================================
# 工具定义
# ==================================================
ASM = nasm
CC  = gcc
CPP = g++
LD	= ld
QEMU = qemu-system-x86_64

# ==================================================
# 目录定义
# ==================================================
s = src
sb = $(s)/boot
sk = $(s)/kernel

t = target
tk = $(t)/kernel

i = include

# ==================================================
# 编译参数
# ==================================================
ASMFLAGS = -I $(sb)/include
ASMFlagsOfKernel= -f elf -I $(sk)/
CFlags	 = -I $(i) -c -fno-builtin -Wall
LDFlags	 = -Ttext $(ENTRYPOINT)

# ==================================================
# 路径定义
# ==================================================
IMG_NAME = LettleOS.img
MOUNT_PATH = /media/LettleOS

# ==================================================
# obj 清单
# ==================================================
KernelObjs = $(tk)/main.o $(tk)/kernel.o $(tk)/kernel_386_lib.o

# ==================================================
# obj 文件生成规则
# ==================================================
$(tk)/main.o: $(sk)/main.c
	mkdir -p $(tk)
	$(CC) $(CFlags) -o $@ $<

$(tk)/kernel.o: $(sk)/kernel.asm
	mkdir -p $(tk)
	$(ASM) $(ASMFlagsOfKernel) -o $@ $<

$(tk)/kernel_386_lib.o:
	mkdir -p $(tk)
	$(ASM) $(ASMFlagsOfKernel) -o $@ $<

# ==================================================
# bin 文件生成规则
# ==================================================
$(t)/boot.bin: $(sb)/boot.asm
	mkdir -p $(t)
	$(ASM) $(ASMFLAGS) $< -o $@
$(t)/loader.bin: $(sb)/loader.asm
	mkdir -p $(t)
	$(ASM) $(ASMFLAGS) $< -o $@

$(t)/kernel.bin: $(KernelObjs)
	mkdir -p $(t)
	$(LD) $(LDFlags) -o $(t)/kernel.bin $^

all: image

run:	
	$(QEMU) -m 512M -fda $(IMG_NAME)
#	bochs -q

image: $(t)/boot.bin $(t)/loader.bin $(t)/kernel.bin
	dd if=/dev/zero of=$(IMG_NAME) bs=512 count=2880
	dd if=$(t)/boot.bin of=$(IMG_NAME) bs=512 count=1 conv=notrunc
	sudo mount -o loop $(IMG_NAME) $(MOUNT_PATH)
	sudo cp $(t)/loader.bin $(MOUNT_PATH)
	sudo cp $(t)/kernel.bin $(MOUNT_PATH)
	sudo umount $(MOUNT_PATH)

clean:
	rm -rf $(t)/*.bin
	rm -rf $(IMG_NAME)