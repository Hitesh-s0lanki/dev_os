# ===========================================
# Top-Level Makefile for Building the OS
# Supports: 
#   - stage1 bootloader (ASM)
#   - stage2 loader (C or ASM)
#   - kernel (ASM or C)
#   - floppy image creation
#   - tools for FAT filesystem
# ===========================================

# -------------------------------------------
# Toolchain Configuration
# -------------------------------------------
ASM = nasm                          # Assembler for stage1, kernel, etc.
CC = gcc                            # Standard C compiler (for tools or stage2)
CC16 = /usr/bin/watcom/binl/wcc    # Watcom C Compiler for 16-bit real mode (optional)
LD16 = /usr/bin/watcom/binl/wlink  # Watcom Linker for 16-bit binaries (optional)

# -------------------------------------------
# Project Directory Structure
# -------------------------------------------
SRC_DIR = src
TOOLS_DIR = tools
BUILD_DIR = build

# -------------------------------------------
# Phony Targets (i.e. not actual files)
# -------------------------------------------
.PHONY: all floppy_image kernel bootloader clean always tools_fat

# -------------------------------------------
# Main Entry Point: Build Everything
# -------------------------------------------
all: floppy_image tools_fat

# -------------------------------------------
# Step 1: Create Floppy Image
# Creates a 1.44MB FAT12 floppy and writes boot & kernel files
# -------------------------------------------
floppy_image: $(BUILD_DIR)/main_floppy.img

$(BUILD_DIR)/main_floppy.img: bootloader kernel
	# Create empty floppy image
	dd if=/dev/zero of=$(BUILD_DIR)/main_floppy.img bs=512 count=2880
	# Format it with FAT12 filesystem
	mkfs.fat -F 12 -n "NBOS" $(BUILD_DIR)/main_floppy.img
	# Copy stage1 bootloader to boot sector (first 512 bytes)
	dd if=$(BUILD_DIR)/stage1.bin of=$(BUILD_DIR)/main_floppy.img conv=notrunc
	# Copy stage2, kernel, and test file into FAT filesystem
	mcopy -i $(BUILD_DIR)/main_floppy.img $(BUILD_DIR)/stage2.bin "::stage2.bin"
	mcopy -i $(BUILD_DIR)/main_floppy.img $(BUILD_DIR)/kernel.bin "::kernel.bin"
	mcopy -i $(BUILD_DIR)/main_floppy.img test.txt "::test.txt"

# -------------------------------------------
# Bootloader (Both Stages)
# -------------------------------------------
bootloader: stage1 stage2

# Stage 1: build stage1 bootloader (boot.asm)
stage1: $(BUILD_DIR)/stage1.bin

$(BUILD_DIR)/stage1.bin: always
	# Delegate to stage1's Makefile
	$(MAKE) -C $(SRC_DIR)/bootloader/stage1 BUILD_DIR=$(abspath $(BUILD_DIR))

# Stage 2: build stage2 bootloader (C or ASM)
stage2: $(BUILD_DIR)/stage2.bin

$(BUILD_DIR)/stage2.bin: always
	# Delegate to stage2's Makefile
	$(MAKE) -C $(SRC_DIR)/bootloader/stage2 BUILD_DIR=$(abspath $(BUILD_DIR))

# -------------------------------------------
# Kernel
# -------------------------------------------
kernel: $(BUILD_DIR)/kernel.bin

$(BUILD_DIR)/kernel.bin: always
	# Delegate to kernel's Makefile
	$(MAKE) -C $(SRC_DIR)/kernel BUILD_DIR=$(abspath $(BUILD_DIR))

# -------------------------------------------
# Tools - Compile FAT12 Reader Tool in C
# -------------------------------------------
tools_fat: $(BUILD_DIR)/tools/fat

$(BUILD_DIR)/tools/fat: always $(TOOLS_DIR)/fat/fat.c
	mkdir -p $(BUILD_DIR)/tools
	# Compile the FAT tool with GCC
	$(CC) -g -o $(BUILD_DIR)/tools/fat $(TOOLS_DIR)/fat/fat.c

# -------------------------------------------
# Create build directory (safe default target)
# -------------------------------------------
always:
	mkdir -p $(BUILD_DIR)

# -------------------------------------------
# Clean all build artifacts
# -------------------------------------------
clean:
	# Clean each module via its own Makefile
	$(MAKE) -C $(SRC_DIR)/bootloader/stage1 BUILD_DIR=$(abspath $(BUILD_DIR)) clean
	$(MAKE) -C $(SRC_DIR)/bootloader/stage2 BUILD_DIR=$(abspath $(BUILD_DIR)) clean
	$(MAKE) -C $(SRC_DIR)/kernel BUILD_DIR=$(abspath $(BUILD_DIR)) clean
	# Wipe build output
	rm -rf $(BUILD_DIR)/*
