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

  mov si, message
  mov ah, BIOS_FUNCTION_DISPLAY_CHAR

  .putstr_loop:
    lodsb
    or al, al
      jz .end_putstr_loop
    int BIOS_FUNCTION
    jmp .putstr_loop
  .end_putstr_loop:

  hlt

message: db "Hello, World!", 0

times MBR_MAX_SIZE_BYTES - ($ - $$) db 0
dw MBR_SIGNATURE
