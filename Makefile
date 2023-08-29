
GCC = gcc
GPP = g++
QEMU = qemu-system-x86_64
ASM = nasm

ASMFLAGS = -I $(sb)/include

s = src
sb = $(s)/boot

t = target

IMG_NAME = LettleOS.img
MOUNT_PATH = /media/LettleOS


$(t)/boot.bin: $(sb)/boot.asm
	mkdir -p $(t)
	$(ASM) $(ASMFLAGS) $< -o $@
$(t)/loader.bin: $(sb)/loader.asm
	mkdir -p $(t)
	$(ASM) $(ASMFLAGS) $< -o $@

bootloader: $(t)/boot.bin $(t)/loader.bin

kernel:

all: image

run:	
	$(QEMU) -m 512M -fda $(IMG_NAME)
#	bochs -q

image: bootloader
	dd if=/dev/zero of=$(IMG_NAME) bs=512 count=2880
	dd if=$(t)/boot.bin of=$(IMG_NAME) bs=512 count=1 conv=notrunc
	sudo mount -o loop $(IMG_NAME) $(MOUNT_PATH)
	sudo cp $(t)/loader.bin $(MOUNT_PATH)
	sudo cp $(t)/kernel.bin $(MOUNT_PATH)
	sudo umount $(MOUNT_PATH)

clean:
	rm -rf $(t)/*.bin
	rm -rf $(IMG_NAME)