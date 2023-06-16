
GCC = gcc
GPP = g++
QEMU = qemu-system-i386
ASM = nasm

ASMFLAGS = -I $(sb)/include

s = src
sb = $(s)/boot

t = target

IMG_NAME=LettleOS.img



$(t)/boot.bin: $(sb)/boot.asm
	mkdir -p $(t)
	$(ASM) $(ASMFLAGS) $< -o $@
$(t)/loader.bin: $(sb)/loader.asm
	mkdir -p $(t)
	$(ASM) $(ASMFLAGS) $< -o $@

all: image

run: all
	$(QEMU) -no-reboot -parallel stdio -hda $(IMG_NAME) -serial null

image: $(t)/boot.bin $(t)/loader.bin
	dd if=/dev/zero of=$(IMG_NAME) bs=512 count=2880
	dd if=$(t)/boot.bin of=$(IMG_NAME) bs=512 count=1 conv=notrunc