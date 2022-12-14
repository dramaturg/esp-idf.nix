{ pkgs ? import
    (builtins.fetchGit {
      name = "nixos-22.11-2022_12_12";
      url = "https://github.com/nixos/nixpkgs/";
      ref = "refs/heads/nixos-22.11";
      rev = "dfef2e61107dc19c211ead99a5a61374ad8317f4";
    })
    { }
}:

with pkgs;
with (import ./. { });
# let
#   flash-micropython-esp32 = writeScriptBin "flash-micropython-esp32" ''
#     PORT=$1
#     if [[ -z "$PORT" ]]; then
#       PORT=/dev/ttyUSB0
#     fi
#     ${esptool}/bin/esptool.py --chip esp32 --port $PORT --baud 460800 write_flash -z 0x1000 ${micropython-esp32}/firmware.bin
#   '';
# in
mkShell {
  name = "esp-idf-env";
  buildInputs = [
    esp32-toolchain
    esp-idf
    esp-idf.python_env
    # flash-micropython-esp32

    esptool
  ];
  shellHook = esp-idf.shellHook;
}
