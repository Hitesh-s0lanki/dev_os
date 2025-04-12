; puts.asm (NASM syntax, 16-bit real mode compatible)
[BITS 16]
[GLOBAL puts]

section .text

puts:
    push ax
    push bx
    push si
    push bp

    mov bp, sp              ; setup frame pointer
    mov si, [bp+6]          ; get argument from stack (Watcom passes arg at [bp+6])

.print_loop:
    lodsb                   ; load byte at DS:SI → AL
    or al, al
    jz .done

    mov ah, 0x0E            ; teletype output
    int 0x10
    jmp .print_loop

.done:
    pop bp
    pop si
    pop bx
    pop ax
    ret
