; mbr.asm - First-stage bootloader (MBR)
org 0x7C00
bits 16

jmp short start
nop

; ---------------------
; Messages
; ---------------------
space       db "---------------------------", 10, 13, 0
loading_msg db "Loading second stage...", 10, 10, 13, 0
error_msg   db "Error loading second stage!", 0

; ---------------------
; Main Code
; ---------------------
start:
    cli
    xor     ax, ax
    mov     ds, ax
    mov     es, ax
    mov     ss, ax
    mov     sp, 0x7C00

    mov     si, space
    call    print_string

    ; Print "Loading second stage..."
    mov     si, loading_msg
    call    print_string

    ; Load second stage bootloader from sector 2 to 0x8000
    mov     bx, 0x8000
    mov     ah, 0x02
    mov     al, 1
    mov     ch, 0
    mov     dh, 0
    mov     cl, 2
    int     0x13
    jc      load_error

    ; Jump to second stage at 0x8000
    jmp     0x0000:0x8000

load_error:
    mov     si, error_msg
    call    print_string
    hlt

print_string:
    mov     ah, 0x0E
.print_char:
    lodsb
    or      al, al
    jz      .done
    int     0x10
    jmp     .print_char
.done:
    ret

; ---------------------
; Boot Signature
; ---------------------
times 510-($-$$) db 0
dw 0xAA55
