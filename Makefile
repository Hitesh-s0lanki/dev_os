# =============================================================
# GadgetOS Top-Level Makefile
# =============================================================

# Object files (unchanged)
FILES = \
  ./build/kernel.asm.o ./build/kernel.o \
  ./build/loader/formats/elf.o ./build/loader/formats/elfloader.o \
  ./build/isr80h/isr80h.o ./build/isr80h/process.o ./build/isr80h/heap.o \
  ./build/keyboard/keyboard.o ./build/keyboard/classic.o \
  ./build/isr80h/io.o ./build/isr80h/misc.o \
  ./build/disk/disk.o ./build/disk/streamer.o \
  ./build/task/process.o ./build/task/task.o ./build/task/task.asm.o ./build/task/tss.asm.o \
  ./build/fs/pparser.o ./build/fs/file.o ./build/fs/fat/fat16.o \
  ./build/string/string.o \
  ./build/idt/idt.asm.o ./build/idt/idt.o \
  ./build/memory/memory.o \
  ./build/io/io.asm.o \
  ./build/gdt/gdt.o ./build/gdt/gdt.asm.o \
  ./build/memory/heap/heap.o ./build/memory/heap/kheap.o \
  ./build/memory/paging/paging.o ./build/memory/paging/paging.asm.o \
  ./build/video/vbe.o \
  ./build/gui/graphics.o \
  ./build/gui/font.o \
  ./build/gui/progressbar.o \
  ./build/gui/screen.o

# Compute directories needed
OBJDIRS := $(sort $(dir $(FILES)))

# Ensure bin directory exists
BINDIR := ./bin

# Include and flags
INCLUDES = -I./src
FLAGS    = -g -ffreestanding -falign-jumps -falign-functions \
           -falign-labels -falign-loops -fstrength-reduce \
           -fomit-frame-pointer -finline-functions \
           -Wno-unused-function -fno-builtin -Werror \
           -Wno-unused-label -Wno-cpp -Wno-unused-parameter \
           -nostdlib -nostartfiles -nodefaultlibs \
           -Wall -O0 -Iinc

# -----------------------------------------------------------------
# Phony targets
# -----------------------------------------------------------------
.PHONY: all user_land clean

# -----------------------------------------------------------------
# Default: build boot, kernel, then user_land programs + OS image
# -----------------------------------------------------------------
all: $(BINDIR)/boot.bin $(BINDIR)/kernel.bin user_land
	@echo "[+] Creating os.bin and copying programs"
	@rm -f $(BINDIR)/os.bin
	@dd if=$(BINDIR)/boot.bin  >> $(BINDIR)/os.bin
	@dd if=$(BINDIR)/kernel.bin >> $(BINDIR)/os.bin
	@dd if=/dev/zero bs=1M count=16 >> $(BINDIR)/os.bin
	@sudo mount -t vfat $(BINDIR)/os.bin /mnt/d
	@sudo cp ./hello.txt /mnt/d
	@sudo cp ./user_land/blank/blank.elf /mnt/d
	@sudo cp ./user_land/shell/shell.elf /mnt/d
	@sudo umount /mnt/d

# -----------------------------------------------------------------
# 1) Directory creation (order-only prerequisites)
# -----------------------------------------------------------------
$(OBJDIRS):
	@mkdir -p $@

$(BINDIR):
	@mkdir -p $@

# -----------------------------------------------------------------
# 2) Build bootloader
# -----------------------------------------------------------------
$(BINDIR)/boot.bin: ./src/boot/boot.asm | $(BINDIR)
	@echo "[AS] boot.asm → boot.bin"
	nasm -f bin $< -o $@

# -----------------------------------------------------------------
# 3) Link kernel
# -----------------------------------------------------------------
$(BINDIR)/kernel.bin: $(FILES) | $(BINDIR)
	@echo "[LD] kernel"
	i686-elf-ld -g -relocatable $(FILES) -o ./build/kernelfull.o
	i686-elf-gcc $(FLAGS) -T ./src/linker.ld \
	              -o $(BINDIR)/kernel.bin -ffreestanding -O0 -nostdlib ./build/kernelfull.o

# -----------------------------------------------------------------
# 4) Pattern rules for .c → .o and .asm → .asm.o
# -----------------------------------------------------------------
./build/%.o: ./src/%.c | $(OBJDIRS)
	@echo "[CC] $< → $@"
	i686-elf-gcc $(INCLUDES) $(FLAGS) -std=gnu99 -c $< -o $@

./build/%.asm.o: ./src/%.asm | $(OBJDIRS)
	@echo "[AS] $< → $@"
	nasm -f elf -g $< -o $@

# ------------------------------------------------------------
# Assemble VBE stub (in src/video/vbe.asm → build/video/vbe.o)
# ------------------------------------------------------------
./build/video/vbe.o: ./src/video/vbe.asm | $(OBJDIRS)
	@echo "[AS] vbe.asm → vbe.o"
	nasm -f elf -g $< -o $@

# -----------------------------------------------------------------
# 5) User land programs (delegate to user_land/Makefile)
# -----------------------------------------------------------------
# user_land:
# 	@echo "[BUILD] user_land programs"
# 	$(MAKE) -C user_land all

# -----------------------------------------------------------------
# 6) Clean
# -----------------------------------------------------------------
clean:
	@echo "[CLEAN] kernel, boot, os image, and build artifacts"
	@rm -rf $(BINDIR)/boot.bin $(BINDIR)/kernel.bin $(BINDIR)/os.bin \
	        ./build/kernelfull.o $(FILES)
	@rm -rf $(OBJDIRS) $(BINDIR)
	$(MAKE) -C user_land clean
