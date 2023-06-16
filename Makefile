# Compiler and linker options
CC = x86_64-linux-gnu-gcc
LD = x86_64-linux-gnu-ld
ASM = nasm
QEMU = qemu-system-x86_64

KERNEL_ENTRY_POINT_PHY_ADDR = 0x1000

CFLAGS = -m32 -I $(INC_DIR) -ffreestanding -fleading-underscore -fno-exceptions -fno-builtin -nostdlib -fno-pie
LDFLAGS = -melf_i386 -no-pie -Ttext $(KERNEL_ENTRY_POINT_PHY_ADDR)
ASMFLAGSforBoot = -f elf -I $(INC_DIR)
ASMFlagsOfKernel= -f elf -I $(INC_DIR)
ASMFlagsOfSysCall = -f elf
ASMFLAGS = -f elf -I $(INC_DIR)

IMG_MOUNT_DIR = /Volumes/LettleOS

# Source file directories
SRC_DIR = src
OBJ_DIR = obj
INC_DIR = libs

# Source files
ASM_SRC = $(wildcard $(SRC_DIR)/*.asm)
C_SRC = $(wildcard $(SRC_DIR)/*.c)

# Object files
ASM_OBJ = $(patsubst $(SRC_DIR)/%.asm,$(OBJ_DIR)/%.o,$(ASM_SRC))
C_OBJ = $(patsubst $(SRC_DIR)/%.c,$(OBJ_DIR)/%.o,$(C_SRC))

# Final output file
BOOT_BIN = boot.bin
KERNEL_BIN = kernel.bin
OS_IMAGE = LettleOS.img

all: $(BOOT_BIN)


image: all
	dd if=/dev/zero of=$(OS_IMAGE) bs=512 count=2880
	dd if=$(BOOT_BIN) of=$(OS_IMAGE) bs=512 count=1 conv=notrunc

# sudo mount -t fat12 -o loop $(OS_IMAGE) $(IMG_MOUNT_DIR)
# sudo cp $(KERNEL_BIN) $(IMG_MOUNT_DIR)
# sudo sync
# sudo umount $(IMG_MOUNT_DIR)

run: image
	$(QEMU) -drive file=$(OS_IMAGE),if=floppy

nop:
	@echo "all          编译所有文件"
	@echo "image        写入image镜像文件"
	@echo "clean        清理所有编译文件"
	@echo "run          用qemu启动虚拟机"

$(BOOT_BIN): boot/boot.asm boot/loader.c
	$(ASM) $(ASMFLAGSforBoot) boot/boot.asm -o $(OBJ_DIR)/boot/boot.o
	$(CC) $(CFLAGS) boot/loader.c -c -o $(OBJ_DIR)/boot/loader.o
	$(LD) -m elf_i386 -nostdlib -T linker.ld $(OBJ_DIR)/boot/boot.o $(OBJ_DIR)/boot/loader.o -o $@

$(KERNEL_BIN): $(ASM_OBJ) $(C_OBJ)
	$(LD) $(LDFLAGS) -o $@ $^

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.asm
	$(ASM) $(ASMFLAGS) $< -o $@

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.c
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -f $(OBJ_DIR)/*.o $(OBJ_DIR)/boot/*.o $(BOOT_BIN) $(OS_IMAGE) $(KERNEL_BIN) $(LOADER_BIN)