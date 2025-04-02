org 0x7C00
bits 16

%define ENDL 0x0D, 0x0A

start:
    jmp main

; ------------------------------------------------------------------------------
; puts - Print a null-terminated string from [SI]
; ------------------------------------------------------------------------------
puts:
    push si
.next:
    lodsb
    test al, al
    jz .done
    mov ah, 0x0E
    int 0x10
    jmp .next
.done:
    pop si
    ret

; ------------------------------------------------------------------------------
; read_input - Read characters into [DI] until Enter is pressed
; ------------------------------------------------------------------------------
read_input:
    xor cx, cx          ; character counter

.read_char:
    mov ah, 0           ; BIOS: Wait for key
    int 0x16
    cmp al, 13          ; Enter key?
    je .done

    ; Echo character to screen
    mov ah, 0x0E
    int 0x10

    ; Store character
    stosb
    inc cx
    jmp .read_char

.done:
    mov al, 0           ; Null terminator
    stosb
    ret

; ------------------------------------------------------------------------------
; main - Program entry
; ------------------------------------------------------------------------------
main:
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00

    ; Print "Enter your name: "
    mov si, prompt
    call puts

    ; Read input into buffer at [input_name]
    mov di, input_name
    call read_input

    ; Print newline
    mov si, newline
    call puts

    ; Print "Hey "
    mov si, greet1
    call puts

    ; Print user's name
    mov si, input_name
    call puts

    ; Print ", how are you?"
    mov si, greet2
    call puts

.halt:
    hlt
    jmp .halt

; ------------------------------------------------------------------------------
; Data
; ------------------------------------------------------------------------------
prompt:    db 'Enter your name: ', 0
greet1:    db 'Hey ', 0
greet2:    db ', how are you?', ENDL, 0
newline:   db ENDL, 0
input_name: times 32 db 0   ; Reserve 32 bytes for name input

; ------------------------------------------------------------------------------
; Boot sector padding + signature
; ------------------------------------------------------------------------------
times 510 - ($ - $$) db 0
dw 0xAA55
