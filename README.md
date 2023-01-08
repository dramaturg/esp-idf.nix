# esp-idf-env.nix [![ESP-IDF v4.4.3](https://img.shields.io/badge/ESP--IDF-v4.4.3-blue.svg)](https://github.com/espressif/esp-idf/tree/6407ecb3f8d2cc07c4c230e7e64f2046af5c86f7) [![crosstool-NG 2021r2-patch5](https://img.shields.io/badge/crosstool--NG-esp--2021r2--patch5-blue.svg)](https://github.com/espressif/crosstool-NG/commit/7dbd58403d012a07ee046836f625985396cfc1ca) [![mach-nix 3.5.0](https://img.shields.io/badge/mach--nix-3.5.0-blue.svg)](https://github.com/DavHau/mach-nix/tree/7e14360bde07dcae32e5e24f366c83272f52923f)
ESP32 IDF development environment manged with nix

This project uses [mach-nix](https://github.com/DavHau/mach-nix) to manage Python dependencies for ESP-IDF.


### Installation
```shell
git clone https://github.com/cyber-murmel/esp-idf.nix.git
```

## Usage
To enter the development environment, call it with `nix-shell`.
```shell
nix-shell ~/path/to/esp-idf.nix/shell.nix
```

### Examples
The examples are to be executed after entering the development environment.

#### MicroPython
```shell
# get code
git clone --branch v1.19 https://github.com/micropython/micropython.git
cd micropython/
make -C ports/esp32 submodules
# build
make -C mpy-cross/
make -C ports/esp32
# set port
export ESP32_PORT=/dev/ttyUSB0
# flash
make -C ports/esp32 deploy PORT=${ESP32_PORT}
# open REPL
python -m serial.tools.miniterm --exit-char 24 --raw --dtr 0 --rts 0 ${ESP32_PORT} 115200
```
