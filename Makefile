# Compiler and linker options
CC = x86_64-elf-gcc
LD = x86_64-elf-ld
ASM = nasm
QEMU = qemu-system-x86_64

KERNEL_ENTRY_POINT_PHY_ADDR = 0x1000

CFLAGS = -c -I $(INC_DIR) -fno-builtin -Wall -m32
LDFLAGS = -melf_i386 -Ttext $(KERNEL_ENTRY_POINT_PHY_ADDR)
ASMFLAGS = -f elf

IMG_MOUNT_DIR = /Volumes/ostest

# Source file directories
SRC_DIR = src
OBJ_DIR = obj
INC_DIR = include

# Source files
ASM_SRC = $(wildcard $(SRC_DIR)/*.asm)
C_SRC = $(wildcard $(SRC_DIR)/*.c)

# Object files
ASM_OBJ = $(patsubst $(SRC_DIR)/%.asm,$(OBJ_DIR)/%.o,$(ASM_SRC))
C_OBJ = $(patsubst $(SRC_DIR)/%.c,$(OBJ_DIR)/%.o,$(C_SRC))

# Final output file
BOOTLOADER_OUTPUT = bootloader.bin
KERNEL_OUTPUT = kernel.bin
OS_IMAGE = ostest.img

all: $(BOOTLOADER_OUTPUT) $(KERNEL_OUTPUT)

image: all
	dd if=/dev/zero of=$(OS_IMAGE) bs=512 count=2880
	dd if=$(BOOTLOADER_OUTPUT) of=$(OS_IMAGE) bs=512 count=1 conv=notrunc
	sudo mount -t nfs -o loop $(OS_IMAGE) $(IMG_MOUNT_DIR)
	sudo cp $(KERNEL_OUTPUT) $(IMG_MOUNT_DIR)
	sudo sync
	sudo umount $(IMG_MOUNT_DIR)

run: image
	$(QEMU) -drive file=$(OS_IMAGE),if=floppy

nop:
	@echo "all          编译所有文件"
	@echo "image        写入image镜像文件"
	@echo "clean        清理所有编译文件"
	@echo "run          用qemu启动虚拟机"

$(BOOTLOADER_OUTPUT): boot/bootloader.asm
	$(ASM) $< -o $@

$(KERNEL_OUTPUT): $(ASM_OBJ) $(C_OBJ)
	$(LD) $(LDFLAGS) -o $@ $^

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.asm
	$(ASM) $(ASMFLAGS) $< -o $@

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.c
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -f $(OBJ_DIR)/*.o $(BOOTLOADER_OUTPUT) $(OS_IMAGE) $(KERNEL_OUTPUT)