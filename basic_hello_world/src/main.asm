org 0x7C00             ; BIOS loads bootloader here
bits 16               ; 16-bit real mode

%define ENDL 0x0D, 0x0A  ; Define newline (carriage return + line feed)

start:
    jmp main           ; Jump to main code

; ------------------------------------------------------------------------------
; puts - Print a null-terminated string pointed to by SI
; ------------------------------------------------------------------------------
puts:
    push si            ; Save SI since we'll modify it

.next_char:
    lodsb              ; Load [SI] into AL, increment SI
    test al, al        ; Check if AL == 0 (null terminator)
    jz .done           ; If yes, end of string

    mov ah, 0x0E       ; BIOS teletype function
    int 0x10           ; Print AL on screen

    jmp .next_char

.done:
    pop si             ; Restore SI
    ret

; ------------------------------------------------------------------------------
; main - Setup segments, print message, halt
; ------------------------------------------------------------------------------
main:
    xor ax, ax         ; AX = 0
    mov ds, ax         ; DS = 0
    mov es, ax         ; ES = 0
    mov ss, ax         ; SS = 0
    mov sp, 0x7C00     ; Stack pointer at end of bootloader

    mov si, msg_hello  ; Load address of message
    call puts          ; Print message

.halt:
    hlt                ; Halt CPU
    jmp .halt          ; Loop forever

; ------------------------------------------------------------------------------
; Data
; ------------------------------------------------------------------------------
msg_hello: db 'Hello world!', ENDL, 0  ; Message with newline and null terminator

; ------------------------------------------------------------------------------
; Boot signature (must be exactly 512 bytes total, ending with 0xAA55)
; ------------------------------------------------------------------------------
times 510 - ($ - $$) db 0              ; Fill the rest with zeros
dw 0xAA55                              ; Boot signature
