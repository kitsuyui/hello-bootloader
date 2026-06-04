# hello world bootloader

I'm trying to write simple bootloader for studying.

## Requirements

Building the bootloader requires these command-line tools:

- `nasm` to assemble `src/helloworld_bootloader.asm` into a raw binary.
- `dd` to create and write the bootloader image.

Running the image locally also requires:

- `qemu-system-x86_64` to boot the generated image in QEMU.

The project is known to build with NASM 3.01. No narrower minimum NASM
version is declared.

On macOS with Homebrew:

```sh
brew install nasm qemu
```

On Debian or Ubuntu:

```sh
sudo apt-get install nasm qemu-system-x86
```

## Build

```sh
make
```

The build writes `build/bootloader_binary.bin` and `build/bootloader.img`.

## Run

```sh
make run-qemu
```
