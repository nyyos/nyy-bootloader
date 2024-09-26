    org 0x7C00
    bits 16

    %define NEXL 0x0D, 0x0A

    jmp short .entry
    nop

.echo:
    push    si
    push    ax
.loop:
    lodsb
    or 	    al, al
    jz 	    .finishedecho

    mov     ah, 0x0E
    mov     bh, 0
    int     0x10

    jmp 	  .loop
.finishedecho:
    pop 	  ax
    pop 	  si
    ret

.entry:
    ; Entry for First Stage Bootloader, its only goal is to
    ; load the Second Stage Bootloader and going to 64bit mode.
    ; Also keep in mind this Bootloader is not designed for
    ; all types of hardware and firmwares so R.I.P my
    ; hard work and labour
.setupstack:
    xor		  ax, ax
    mov 	  ds, ax
    mov 	  es, ax

    mov 	  ss, ax
    mov 	  sp, 0x7C00

; ------Bad-Stuff------
.failmessage:
    mov 	  si, Fail
    call	  .echo
.hlt:
    hlt
    jmp		  .hlt
; ---------------------

; ---Define-Variables--
    Fail:
            db '[CRITICAL] Entering Stage2 Bootloading failed', NEXL, 0
; ---------------------

; 446 bytes, start of partition table (64 bytes overall, 16 bytes each)
times 446-($-$$) db 0

; Remaining 4 partitions
times 64 db 0
        dw 0xAA55 ; MBR Boot Signature
