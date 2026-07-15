; http://blog.ackx.net/asm-hello-world-bootloader.html
; http://www.osdever.net/tutorials/view/hello-world-boot-loader
; https://www.glamenv-septzen.net/en/view/6
; https://en.wikipedia.org/wiki/Master_boot_record

org 0x7C00
bits 16

%define MBR_SIGNATURE 0xAA55
%define MBR_MAX_SIZE_BYTES 510
%define BIOS_FUNCTION_DISPLAY_CHAR 0x0E
%define BIOS_FUNCTION_SET_VIDEO_MODE 0x00
%define BIOS_FUNCTION 0x10
%define VIDEO_MODE_TEXT_80x25 0x03
%define COM1_PORT 0x3F8
%define COM1_INTERRUPT_ENABLE_PORT COM1_PORT + 1
%define COM1_FIFO_CONTROL_PORT COM1_PORT + 2
%define COM1_LINE_CONTROL_PORT COM1_PORT + 3
%define COM1_MODEM_CONTROL_PORT COM1_PORT + 4
%define COM1_LINE_STATUS_PORT COM1_PORT + 5
%define COM1_LINE_STATUS_TRANSMIT_READY 0x20

start:
  cli
  xor ax, ax
  mov ds, ax
  mov es, ax
  mov ss, ax
  mov sp, 0x7C00
  cld
  sti

  mov ah, BIOS_FUNCTION_SET_VIDEO_MODE
  mov al, VIDEO_MODE_TEXT_80x25
  int BIOS_FUNCTION

  call initialize_serial
  mov si, message
  mov ah, BIOS_FUNCTION_DISPLAY_CHAR
  xor bh, bh  ; INT 10h AH=0Eh expects BH=0 (video page 0)

  .putstr_loop:
    lodsb
    or al, al
      jz .end_putstr_loop
    call write_serial_char
    mov ah, BIOS_FUNCTION_DISPLAY_CHAR
    int BIOS_FUNCTION
    jmp .putstr_loop
  .end_putstr_loop:

.halt:
  hlt
  jmp .halt

initialize_serial:
  mov dx, COM1_INTERRUPT_ENABLE_PORT
  xor al, al
  out dx, al

  mov dx, COM1_LINE_CONTROL_PORT
  mov al, 0x80
  out dx, al

  mov dx, COM1_PORT
  mov al, 0x03
  out dx, al

  mov dx, COM1_INTERRUPT_ENABLE_PORT
  xor al, al
  out dx, al

  mov dx, COM1_LINE_CONTROL_PORT
  mov al, 0x03
  out dx, al

  mov dx, COM1_FIFO_CONTROL_PORT
  mov al, 0xC7
  out dx, al

  mov dx, COM1_MODEM_CONTROL_PORT
  mov al, 0x0B
  out dx, al
  ret

write_serial_char:
  push ax

  .wait_for_transmit_ready:
    mov dx, COM1_LINE_STATUS_PORT
    in al, dx
    test al, COM1_LINE_STATUS_TRANSMIT_READY
    jz .wait_for_transmit_ready

  pop ax
  push ax
  mov dx, COM1_PORT
  out dx, al
  pop ax
  ret

message: db "Hello, World!", 0

times MBR_MAX_SIZE_BYTES - ($ - $$) db 0
dw MBR_SIGNATURE
