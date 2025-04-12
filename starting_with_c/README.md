Basic Requirement

- any text editor
- Make
- Nasm -assembler
- qemu (hypervisor)

install code

---

    make            # Builds bootloader, kernel, floppy image, and fat tool
    make run        # Launches QEMU with the floppy
    make clean      # Removes everything in build/

    ./build/tools/fat build/main_floppy.img "TEST    TXT"

---

Execution Code

---

    make
    qemu-system-i386 -drive file=build/main_floppy.img,format=raw,index=0,if=floppy

---

> **Warning**: Please change the parameter `FILE_NAME` in the `Makefile` file accordingly before executing the commands.
