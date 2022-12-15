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
mkShell {
  name = "esp-idf-env";
  buildInputs = [
    esp32-toolchain
    esp-idf
    esp-idf.python_env

    esptool
  ];
  shellHook = esp-idf.shellHook;
}
