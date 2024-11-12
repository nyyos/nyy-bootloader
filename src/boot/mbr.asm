org 0x7C00
bits 16

jmp start
nop

times 8-($-$$) db 0
boot_info:
    bi_PVD dd 0
    bi_boot_LBA dd 0
    bi_boot_len dd 0
    bi_checksum dd 0
    bi_rsv times 40 db 0

times 90-($-$$) db 0

; ---------------------
; Main Code
; ---------------------
start:
    cli
    cld
    xor     ax, ax
    mov     ds, ax
    mov     es, ax
    mov     ss, ax
    mov     si, ax
    mov     sp, 0x7C00      ; Adjusted stack pointer

    ; Print "Loading second stage..."
    mov     si, loading_msg
    call    print_string

    ; Load second stage bootloader from sector 2 to 0x8000
    mov     bx, 0x8000
    mov     ah, 0x02
    mov     al, 1
    mov     ch, 0           ; track
    mov     cl, 1           ; sector
    mov     dh, 0           ; head
    mov     dl, 0xE0        ; Assuming primary hard drive
    int     0x13
    ;jc      load_error

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
; Messages
; ---------------------
loading_msg db "Loading second stage...", 10, 13, 0
error_msg   db "Error loading second stage!", 0

; ---------------------
; Boot Signature
; ---------------------
times 510-($-$$) db 0
dw 0xAA55
