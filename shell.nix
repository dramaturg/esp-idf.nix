{ pkgs ? import
    (builtins.fetchGit {
      name = "nixos-22.11-2023_01_08";
      url = "https://github.com/nixos/nixpkgs/";
      ref = "refs/heads/nixos-22.11";
      rev = "2dea8991d89b9f1e78d874945f78ca15f6954289";
    })
    { }
}:

with pkgs;
with (import ./. { });
mkShell {
  name = "esp-idf-env";
  buildInputs = [
    esp32-toolchain
    esp-idf

    esptool
  ];
  shellHook = esp-idf.shellHook + ''
    export IDF_PATH=${esp-idf}/esp-idf
  '';
}
