Requirement

- any text editor
- Make
- Nasm -assembler
- qemu (hypervisor)

install code

---

    apt install make nasm qemu

---

Execution Code

---

    make
    qemu-system-i386 -drive file=build/main_floppy.img,format=raw,index=0,if=floppy

---

> **Warning**: Please change the parameter `FILE_NAME` in the `Makefile` file accordingly before executing the commands.
