#!/bin/bash

# Clean up any previous builds
rm -rf output.iso iso

# Create a temporary directory structure for the ISO
mkdir -p iso/boot/grub

# ------------------------------
# Build the Bootloader (MBR + Loader)
# ------------------------------
# Assemble the bootloader and create binary files
nasm -f bin -o src/boot/mbr.bin src/boot/mbr.asm
nasm -f bin -o src/boot/loader.bin src/boot/loader.asm

# Copy bootloader files to the ISO directory
cp src/boot/mbr.bin iso/boot/
cp src/boot/loader.bin iso/boot/

# -------------------------
# Compile the 64-bit Kernel
# -------------------------
# Compile the kernel64.c file into an object file
gcc -ffreestanding -m64 -c src/boot/kernel64.c -o src/boot/kernel64.o

# Link the kernel object file to create a kernel binary
ld -o iso/boot/kernel64.bin -m elf_x86_64 -Ttext 0x100000 src/boot/kernel64.o

# -------------------------------
# Create the GRUB Configuration File
# -------------------------------
cat > iso/boot/grub/grub.cfg <<EOF
menuentry "My 64-bit OS" {
    multiboot /boot/kernel64.bin
    boot
}
EOF

# --------------------------------------
# Create the ISO Image Using xorriso
# --------------------------------------
xorriso -as mkisofs -r -b boot/mbr.bin -no-emul-boot -boot-load-size 4 -boot-info-table -o output.iso iso/

# Clean up temporary directory
rm -rf iso
