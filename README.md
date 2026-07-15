# hello world bootloader

I'm trying to write simple bootloader for studying.

## Requirements

Building the bootloader requires these command-line tools:

- `nasm` to assemble `src/helloworld_bootloader.asm` into a raw binary.
- `dd` to create and write the bootloader image.

Running the image locally also requires:

- `qemu-system-x86_64` to boot the generated image in QEMU.
  QEMU must be built with a graphical display backend (such as SDL on Linux or Cocoa on macOS).
  Headless environments without a display are not supported by `make run-qemu`.
  The automated smoke test uses QEMU headlessly and captures the same boot message through COM1.

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

## Runtime Smoke Test

```sh
make check
```

This boots the generated image in headless QEMU, captures the boot message from COM1,
and fails unless `Hello, World!` is observed in the runtime output.

## Development

Install [lefthook](https://github.com/evilmartians/lefthook) and register the hooks:

```sh
lefthook install
```

This sets up the following local checks that run before every commit and push:

- **spellcheck** – runs `typos` to catch spelling mistakes, mirroring the `spellcheck` CI job.
- **build** – assembles the bootloader with `make` (requires `nasm`) and then runs `make clean` to leave the tree clean.
- **runtime smoke test** – runs `make check` to verify that the booted image emits `Hello, World!` through the automated QEMU observation path.

If either tool is not installed, the corresponding hook will fail. Install the missing tool or remove the relevant entry from `lefthook.yml` for your local setup.
