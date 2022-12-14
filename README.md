# esp-idf-env.nix
ESP32 IDF development environment manged with nix

This project makes use of [mach-nix](https://github.com/DavHau/mach-nix) to manage Python dependencies for ESP-IDF.

### Installation
```shell
git clone --recurse-submodules https://github.com/cyber-murmel/esp-idf.nix.git
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
