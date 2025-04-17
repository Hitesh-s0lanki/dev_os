; -------------------------------------------------------------------
; vbe.asm — VBE mode‑setting stub
; -------------------------------------------------------------------
[BITS 16]
default rel

; Export the mode‑set function
global vbe_set_mode

; VBE mode constants
%define VBE_MODE 0x118    ; 1024×768, 32 bpp
%define VBE_LFB   0x4000   ; Linear Framebuffer bit

section .text
vbe_set_mode:
    mov ax, 0x4F02             ; VBE: Set Video Mode
    mov bx, VBE_MODE | VBE_LFB ; Mode number + LFB flag
    int 0x10                   ; BIOS interrupt
    ret
