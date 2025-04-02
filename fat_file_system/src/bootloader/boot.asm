org 0x7C00
bits 16

%define ENDL 0x0D, 0x0A

; ------------------------------------------------------------------------------
; FAT12 BIOS Parameter Block (BPB) + Extended Boot Record (EBR)
; Required for booting on real hardware / FAT12-compliant systems
; ------------------------------------------------------------------------------

jmp short start         ; Jump to code (FAT12 requirement)
nop                     ; Padding

bdb_oem:                db 'MSWIN4.1'       ; OEM Name
bdb_bytes_per_sector:   dw 512
bdb_sectors_per_cluster: db 1
bdb_reserved_sectors:   dw 1
bdb_fat_count:          db 2
bdb_dir_entries_count:  dw 0E0h
bdb_total_sectors:      dw 2880
bdb_media_descriptor:   db 0F0h
bdb_sectors_per_fat:    dw 9
bdb_sectors_per_track:  dw 18
bdb_heads:              dw 2
bdb_hidden_sectors:     dd 0
bdb_large_sector_count: dd 0

ebr_drive_number:       db 0
                        db 0               ; Reserved
ebr_signature:          db 0x29
ebr_volume_id:          db 0x12, 0x34, 0x56, 0x78
ebr_volume_label:       db 'NANOBYTE OS'   ; 11 bytes
ebr_system_id:          db 'FAT12   '       ; 8 bytes

; ------------------------------------------------------------------------------
; Start of code
; ------------------------------------------------------------------------------

start:
    jmp main

; ------------------------------------------------------------------------------
; Print null-terminated string at DS:SI
; ------------------------------------------------------------------------------

puts:
    push si
    push ax
    push bx
.loop:
    lodsb
    or al, al
    jz .done
    mov ah, 0x0E
    mov bh, 0
    int 0x10
    jmp .loop
.done:
    pop bx
    pop ax
    pop si
    ret

; ------------------------------------------------------------------------------
; Main boot logic
; ------------------------------------------------------------------------------

main:
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00

    ; Save BIOS-passed drive number
    mov [ebr_drive_number], dl

    ; Read 1 sector from LBA = 1 into 0x7E00
    mov ax, 1               ; LBA sector number
    mov cl, 1               ; number of sectors to read
    mov bx, 0x7E00          ; memory destination
    call disk_read

    ; Optional: print a message
    mov si, msg_loaded
    call puts

    ; Jump to loaded kernel at 0x7E00
    jmp 0x0000:0x7E00

.halt:
    cli
    hlt
    jmp .halt

; ------------------------------------------------------------------------------
; Handle disk read error
; ------------------------------------------------------------------------------

floppy_error:
    mov si, msg_read_failed
    call puts
    jmp wait_key_and_reboot

wait_key_and_reboot:
    mov ah, 0
    int 16h             ; Wait for key
    jmp 0FFFFh:0        ; Reboot

; ------------------------------------------------------------------------------
; Convert LBA to CHS
; AX: LBA
; Returns: CX, DH = CHS values
; ------------------------------------------------------------------------------

lba_to_chs:
    push ax
    push dx

    xor dx, dx
    div word [bdb_sectors_per_track] ; AX / sectors per track
    inc dx                           ; Sector = remainder + 1
    mov cx, dx

    xor dx, dx
    div word [bdb_heads]            ; AX / heads
    mov dh, dl                      ; Head
    mov ch, al                      ; Cylinder low 8 bits
    shl ah, 6
    or cl, ah                       ; Put high 2 bits of cylinder in CL

    pop dx
    pop ax
    ret

; ------------------------------------------------------------------------------
; Read sectors using BIOS INT 13h
; AX = LBA, CL = count, BX = destination, DL = drive number
; ------------------------------------------------------------------------------

disk_read:
    push ax
    push bx
    push cx
    push dx
    push di

    push cx
    call lba_to_chs
    pop ax                      ; sector count in AL

    mov ah, 0x02                ; BIOS read sector function
    mov di, 3                   ; retry count

.retry:
    pusha
    stc                         ; Set carry flag
    int 13h
    jnc .success                ; No error? jump

    popa
    call disk_reset
    dec di
    jnz .retry

.fail:
    jmp floppy_error

.success:
    popa
    pop di
    pop dx
    pop cx
    pop bx
    pop ax
    ret

; ------------------------------------------------------------------------------
; Reset disk controller
; ------------------------------------------------------------------------------

disk_reset:
    pusha
    mov ah, 0
    stc
    int 13h
    popa
    ret

; ------------------------------------------------------------------------------
; Strings
; ------------------------------------------------------------------------------
msg_read_failed: db 'Disk read failed!', ENDL, 0
msg_loaded: db 'Kernel loaded successfully.', ENDL, 0

; ------------------------------------------------------------------------------
; Boot sector padding and signature
; ------------------------------------------------------------------------------
times 510 - ($ - $$) db 0
dw 0xAA55
