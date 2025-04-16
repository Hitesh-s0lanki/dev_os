#/bin/bash

make clean

export PREFIX="/home/ubuntu/Desktop/toolchain/i686-elf"
export TARGET="i686-elf"
export PATH="$PREFIX/bin:$PATH"

make all

qemu-system-x86_64 ./bin/os.bin