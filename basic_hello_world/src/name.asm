org 0x7C00
bits 16

%define ENDL 0x0D, 0x0A  ; New line (carriage return + line feed)

start:
    jmp main             ; Jump to main

; ------------------------------------------------------------------------------
; puts - Print a null-terminated string pointed to by SI
; ------------------------------------------------------------------------------
puts:
    push si              ; Save SI

.next_char:
    lodsb                ; Load byte at SI into AL, increment SI
    test al, al          ; Check if null terminator
    jz .done

    mov ah, 0x0E         ; BIOS teletype function
    int 0x10             ; Print character in AL

    jmp .next_char

.done:
    pop si               ; Restore SI
    ret

; ------------------------------------------------------------------------------
; main - Setup segments and print names
; ------------------------------------------------------------------------------
main:
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00

    ; Print Name 1
    mov si, name1
    call puts

    ; Print newline
    mov si, newline
    call puts

    ; Print Name 2
    mov si, name2
    call puts

    ; Print newline
    mov si, newline
    call puts

    ; Print Name 3
    mov si, name3
    call puts

.halt:
    hlt
    jmp .halt

; ------------------------------------------------------------------------------
; Data section
; ------------------------------------------------------------------------------
name1: db 'Alice', 0
name2: db 'Bob', 0
name3: db 'Charlie', 0
newline: db ENDL, 0

; ------------------------------------------------------------------------------
; Boot sector padding and signature
; ------------------------------------------------------------------------------
times 510 - ($ - $$) db 0
dw 0xAA55
