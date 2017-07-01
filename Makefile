sources = src/helloworld_bootloader.asm
bootloader_binary = build/bootloader_binary.bin
bootloader_image = build/bootloader.img

.PHONY: all
all: $(bootloader_image)

$(bootloader_binary): $(sources)
	nasm -f bin -o $(bootloader_binary) $(sources)

$(bootloader_image): $(bootloader_binary)
	dd if=/dev/zero of=$(bootloader_image) bs=512 count=2
	dd conv=notrunc if=$(bootloader_binary) of=$(bootloader_image)

run-qemu: $(bootloader_image)
	qemu-system-x86_64 \
		-monitor stdio \
		-vnc :0,password \
		-drive file=$(bootloader_image),format=raw

.PHONY: clean
clean:
	rm -f $ $(bootloader_image)
