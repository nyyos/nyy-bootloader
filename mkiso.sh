#!/bin/bash

rm -rf output.iso iso
mkdir -p iso/boot

nasm -f bin -o iso/boot/mbr.bin src/boot/mbr.asm
nasm -f bin -o iso/boot/loader.bin src/boot/loader.asm

gcc -ffreestanding -m64 -c src/boot/kernel64.c -o src/boot/kernel64.o
ld -o iso/boot/kernel64.bin -m elf_x86_64 -Ttext 0x100000 src/boot/kernel64.o --oformat binary

xorriso -as mkisofs -r \
  -b boot/mbr.bin \
  -no-emul-boot -boot-load-size 4 -boot-info-table \
  -o output.iso iso/

rm -rf iso
