; loader.asm - Second stage bootloader with 64-bit mode transition
org 0x8000
bits 16

; ---------------------
; Bootloader Entry Point
; ---------------------
start:
    ;cli                     ; Clear interrupts
    ;xor     ax, ax
    ;mov     ds, ax
    ;mov     es, ax

    ; Print message before entering 32-bit mode
    mov     si, stage2_msg
    call    print_string

    cli

    ; Set up GDT for 32-bit mode
    lgdt    [gdt_descriptor]  ; Load GDT descriptor

    ; Enable protected mode (set PE bit in CR0)
    mov     eax, cr0
    or      eax, 1
    mov     cr0, eax

    ; Far jump to update CS and switch to protected mode
    jmp     CODE_SEG:init_pm

[BITS 32]
init_pm:
    ; In 32-bit mode: set up data segments
    mov     ax, DATA_SEG
    mov     ds, ax
    mov     es, ax
    mov     ss, ax

    ; Print message before entering 64-bit mode
    mov     si, mode64_msg
    call    print_string

    ; Set up GDT for 64-bit mode
    lgdt    [gdt64_descriptor]

    ; Enable 64-bit mode (set LME bit in CR4)
    mov     eax, cr4
    or      eax, 0x2000          ; Set LME (Long Mode Enable)
    mov     cr4, eax

    ; Set PE bit in CR0 to enable protected mode
    mov     eax, cr0
    or      eax, 0x80000000      ; Set PE (Protected Mode Enable)
    mov     cr0, eax

    ; Far jump to 64-bit mode
    jmp     CODE64_SEG:init_64bit

[BITS 64]
init_64bit:
    ; In 64-bit mode: set up data segments for 64-bit
    mov     ax, DATA64_SEG
    mov     ds, ax
    mov     es, ax
    mov     ss, ax

    ; Kernel main entry in 64-bit mode
    ; Call kernel function here (assumed to be loaded already)

    ; Halt CPU (infinite loop)
    hlt

; ---------------------
; Print String Function
; ---------------------
print_string:
    ; Print string pointed to by SI using BIOS interrupt 0x10
    mov     ah, 0x0E
.print_char:
    lodsb                       ; Load next byte of string into AL
    or      al, al              ; Check if end of string
    jz      .done
    int     0x10               ; Print character
    jmp     .print_char

.done:
    ret

; ---------------------
; GDT for 32-bit and 64-bit Mode
; ---------------------
gdt:
    dq      0x0000000000000000  ; Null descriptor
    dq      0x00AF9A000000FFFF  ; Code descriptor (32-bit)
    dq      0x00AF92000000FFFF  ; Data descriptor (32-bit)
    
gdt64:
    dq      0x0000000000000000  ; Null descriptor
    dq      0x00AF9A000000FFFF  ; Code descriptor (64-bit)
    dq      0x00AF92000000FFFF  ; Data descriptor (64-bit)
    
gdt_descriptor:
    dw      gdt_end - gdt - 1   ; Limit
    dd      gdt                 ; Base address

gdt64_descriptor:
    dw      gdt64_end - gdt64 - 1 ; Limit
    dd      gdt64                ; Base address

gdt_end:
gdt64_end:

CODE_SEG     equ 0x08
DATA_SEG     equ 0x10
CODE64_SEG   equ 0x18
DATA64_SEG   equ 0x20

; ---------------------
; Message Definitions
; ---------------------
stage2_msg db "Entered Stage 2 Bootloading...", 0
mode64_msg db "Entering 64-bit mode...", 0
