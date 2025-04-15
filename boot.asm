org 0x7c00
BITS 16

start:
    mov si, message
    call print
    jmp $

print:
    mov bx, 0
._loop:
    lodsb
    cmp al, 0
    je .done
    call print_char
    jmp ._loop

.done:
    ret

print_char:
    mov ah, 0eh
    int 0x10
    ret

message: db 'hello world!', 0

times 510 - ($ - $$) db 0
dw 0xAA55