
GCC = gcc
GPP = g++
QEMU = qemu-system-i386


s = src
sb = $(s)/boot

t = target

IMG_NAME=LettleOS.img



$(t)/boot.bin: $(sb)/boot.asm
	mkdir -p $(t)
	nasm $< -o $@

all: image

run: all
	$(QEMU) -no-reboot -parallel stdio -hda $(IMG_NAME) -serial null

image: $(t)/boot.bin
	dd if=/dev/zero of=$(IMG_NAME) bs=512 count=2880
	dd if=$(t)/boot.bin of=$(IMG_NAME) bs=512 count=1 conv=notrunc