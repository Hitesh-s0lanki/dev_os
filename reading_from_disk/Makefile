ASM = nasm
SRC_DIR = src
BUILD_DIR = build

BOOTLOADER_SRC = $(SRC_DIR)/bootloader/boot.asm
KERNEL_SRC     = $(SRC_DIR)/kernel/main.asm

BOOTLOADER_BIN = $(BUILD_DIR)/bootloader.bin
KERNEL_BIN     = $(BUILD_DIR)/kernel.bin
FLOPPY_IMG     = $(BUILD_DIR)/main_floppy.img

.PHONY: all clean run

all: $(FLOPPY_IMG)

# Build the floppy image
$(FLOPPY_IMG): $(BOOTLOADER_BIN) $(KERNEL_BIN)
	dd if=/dev/zero of=$(FLOPPY_IMG) bs=512 count=2880
	mkfs.fat -F 12 -n "NBOS" $(FLOPPY_IMG)
	dd if=$(BOOTLOADER_BIN) of=$(FLOPPY_IMG) conv=notrunc
	dd if=$(KERNEL_BIN) of=$(FLOPPY_IMG) bs=512 seek=1 conv=notrunc

# Assemble bootloader and kernel
$(BOOTLOADER_BIN): $(BOOTLOADER_SRC)
	mkdir -p $(BUILD_DIR)
	$(ASM) $< -f bin -o $@

$(KERNEL_BIN): $(KERNEL_SRC)
	mkdir -p $(BUILD_DIR)
	$(ASM) $< -f bin -o $@

# Run with QEMU
run: all
	qemu-system-i386 -fda $(FLOPPY_IMG)

# Clean build files
clean:
	rm -rf $(BUILD_DIR)/*
