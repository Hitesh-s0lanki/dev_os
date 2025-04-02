ASM = nasm
CC = gcc

SRC_DIR = src
TOOLS_DIR = tools
BUILD_DIR = build

BOOTLOADER_SRC = $(SRC_DIR)/bootloader/boot.asm
KERNEL_SRC = $(SRC_DIR)/kernel/main.asm
FAT_TOOL_SRC = $(TOOLS_DIR)/fat/fat.c

BOOTLOADER_BIN = $(BUILD_DIR)/bootloader.bin
KERNEL_BIN = $(BUILD_DIR)/kernel.bin
FLOPPY_IMG = $(BUILD_DIR)/main_floppy.img
FAT_TOOL = $(BUILD_DIR)/tools/fat

.PHONY: all floppy_image kernel bootloader clean always tools_fat run

# ------------------------------------------------------------------------------
# Main entry point
# ------------------------------------------------------------------------------
all: floppy_image tools_fat

# ------------------------------------------------------------------------------
# Create full floppy image
# ------------------------------------------------------------------------------
floppy_image: $(FLOPPY_IMG)

$(FLOPPY_IMG): $(BOOTLOADER_BIN) $(KERNEL_BIN) test.txt
	@echo "[+] Creating floppy image..."
	dd if=/dev/zero of=$@ bs=512 count=2880
	mkfs.fat -F 12 -n "NBOS" $@
	dd if=$(BOOTLOADER_BIN) of=$@ conv=notrunc
	@if [ -f test.txt ]; then \
		mcopy -i $@ test.txt "::test.txt"; \
	fi
	mcopy -i $@ $(KERNEL_BIN) "::kernel.bin"

# ------------------------------------------------------------------------------
# Assemble bootloader
# ------------------------------------------------------------------------------
bootloader: $(BOOTLOADER_BIN)

$(BOOTLOADER_BIN): $(BOOTLOADER_SRC) | always
	$(ASM) $< -f bin -o $@

# ------------------------------------------------------------------------------
# Assemble kernel
# ------------------------------------------------------------------------------
kernel: $(KERNEL_BIN)

$(KERNEL_BIN): $(KERNEL_SRC) | always
	$(ASM) $< -f bin -o $@

# ------------------------------------------------------------------------------
# Build FAT tool
# ------------------------------------------------------------------------------
tools_fat: $(FAT_TOOL)

$(FAT_TOOL): $(FAT_TOOL_SRC) | always
	mkdir -p $(BUILD_DIR)/tools
	$(CC) -g -o $@ $<

# ------------------------------------------------------------------------------
# Create build directory
# ------------------------------------------------------------------------------
always:
	mkdir -p $(BUILD_DIR)

# ------------------------------------------------------------------------------
# Clean build
# ------------------------------------------------------------------------------
clean:
	rm -rf $(BUILD_DIR)

# ------------------------------------------------------------------------------
# Run the image with QEMU
# ------------------------------------------------------------------------------
run: all
	qemu-system-i386 -fda $(FLOPPY_IMG)
