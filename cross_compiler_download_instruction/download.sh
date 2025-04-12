    #!/bin/bash

    # Update the system
    sudo update

    # Create a new directory
    mkdir new

    # List the contents of the current directory
    ls

    # Clear the terminal
    clear

    # Navigate to the Toolchain directory
    cd /home/gadgetOS/Toolchain/

    # Download the binutils source code
    wget https://ftp.gnu.org/gnu/binutils/binutils-2.37.tar.xz

    # Extract the binutils archive
    tar -xvf binutils-2.37.tar.xz

    # Set up environment variables for the toolchain
    export PREFIX="$HOME/gadgetOS/Toolchain/i686-elf"
    export TARGET=i686-elf
    export PATH="$PREFIX/bin:$PATH"

    # Clear the terminal
    clear

    # Extract the GCC source code
    tar -xvf gcc-11.1.0.tar.gz

    # List the contents of the current directory
    ls

    # Clear the terminal
    clear

    # Create a build directory for binutils
    mkdir binutils-build

    # Navigate to the binutils source directory
    cd binutils-

    # Navigate to the binutils build directory
    cd binutils-build/

    # Clear the terminal
    clear

    # Configure the binutils build
    ../binutils-2.37/configure --target=$TARGET --prefix="$PREFIX" --with-sysroot --disable-nls --disable-werror

    # Build binutils
    make -j 4

    # Install binutils
    make install

    # Verify the binutils installation
    i686-elf-ld

    # Navigate back to the Toolchain directory
    cd ..

    # Create a build directory for GCC
    mkdir gcc-build

    # Navigate to the GCC build directory
    cd gcc-build/

    # Configure the GCC build
    ../gcc-11.1.0/configure --target=