org 0x7C00
bits 16

%define NEXL 0x0D, 0x0A

jmp short .entry
nop

.echo:
    push 	si
    push 	ax
.loop:
    lodsb
    or 		al, al
    jz 		.finishedecho

    mov 	ah, 0x0E
    mov 	bh, 0
    int 	0x10

    jmp 	.loop
.finishedecho:
    pop 	ax
    pop 	si
    ret

.entry:
    ; Entry for First Stage Bootloader, its only goal is to
    ; load the Second Stage Bootloader and going to 32bit mode.
    ; Also keep in mind this Bootloader is not designed for
    ; all types of hardware and firmwares so R.I.P my
    ; hard work and labour
.setupstack:
    xor		ax, ax
    mov 	ds, ax
    mov 	es, ax

    mov 	ss, ax
    mov 	sp, 0x7C00
.entrymessage:
    mov 	si, Entered
    call 	.echo

.failuremessage:
    mov 	si, Failure
    call	.echo
.hlt:
    hlt
    jmp		.hlt

; Define Variables
    Entered: 
        db '[INFO] Entered Stage1 Bootloading', NEXL, 0
    Entering:
        db '[INFO] Entering Stage2 Bootloading', NEXL, 0
    Failure:
        db '[CRITICAL] Entering Stage2 Bootloading failed', NEXL, 0

; Padding to ensure the bootloader code is 446 bytes
times 446-($-$$) db 0

; Partition Table Entry (64 bytes total)

; Partition 1 (Active ext2 Partition)
.partitiontable
    db 0x80                ; Bootable flag (0x80 = active)
    db 0x01, 0x01, 0x00    ; Starting CHS (legacy BIOS ignored, safe to set like this)
    db 0x83                ; Partition type (0x83 = ext2/ext3/ext4)
    db 0xFE, 0xFF, 0xFF    ; Ending CHS (legacy BIOS ignored)
    dd 0x0000003F          ; Starting sector (LBA 63)
    dd 0x1DBE7BF           ; Partition size in sectors (15GB example)

; Empty entries for remaining 3 partitions (16 bytes each)
times 64-16 db 0
; MBR signature
dw 0xAA55
