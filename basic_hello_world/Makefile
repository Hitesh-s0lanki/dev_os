ASM=nasm

SRC_DIR=src
BUILD_DIR=build
FILE_NAME=main

$(BUILD_DIR)/$(FILE_NAME)_floppy.img: $(BUILD_DIR)/$(FILE_NAME).bin
	cp $(BUILD_DIR)/$(FILE_NAME).bin $(BUILD_DIR)/$(FILE_NAME)_floppy.img
	truncate -s 1440k $(BUILD_DIR)/$(FILE_NAME)_floppy.img
	
$(BUILD_DIR)/$(FILE_NAME).bin: $(SRC_DIR)/$(FILE_NAME).asm
	mkdir -p $(BUILD_DIR)
	$(ASM) $(SRC_DIR)/$(FILE_NAME).asm -f bin -o $(BUILD_DIR)/$(FILE_NAME).bin