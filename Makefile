sources = src/helloworld_bootloader.asm
bootloader_binary = build/bootloader_binary.bin
bootloader_image = build/bootloader.img
runtime_output = build/runtime-output.txt

.DELETE_ON_ERROR:

.PHONY: all
all: $(bootloader_image)

$(bootloader_binary): $(sources)
	mkdir -p build
	nasm -f bin -o $(bootloader_binary) $(sources)

$(bootloader_image): $(bootloader_binary)
	dd if=/dev/zero of=$(bootloader_image) bs=512 count=2
	dd conv=notrunc if=$(bootloader_binary) of=$(bootloader_image)

run-qemu: $(bootloader_image)
	qemu-system-x86_64 \
		-monitor stdio \
		-drive file=$(bootloader_image),format=raw

.PHONY: check
check: $(bootloader_image)
	mkdir -p build
	rm -f $(runtime_output)
	tmp_output="$$(mktemp)"; \
	trap 'rm -f "$$tmp_output"' EXIT INT TERM; \
	qemu-system-x86_64 \
		-display none \
		-monitor none \
		-serial file:"$$tmp_output" \
		-drive file=$(bootloader_image),format=raw \
		-pidfile build/qemu.pid & \
	qemu_pid=$$!; \
	sleep 1; \
	if kill -0 "$$qemu_pid" 2>/dev/null; then kill "$$qemu_pid" 2>/dev/null || true; fi; \
	wait "$$qemu_pid" 2>/dev/null || true; \
	mv "$$tmp_output" $(runtime_output); \
	grep -F "Hello, World!" $(runtime_output)

.PHONY: clean
clean:
	rm -f $(bootloader_image) $(bootloader_binary) $(runtime_output) build/qemu.pid
