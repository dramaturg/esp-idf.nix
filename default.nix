{ sources ? import ../sources.nix, pkgs ? import sources.nixpkgs { } }:

with pkgs; rec {
  esp32-toolchain = callPackage ./esp32-toolchain.nix { };

  esp-idf = callPackage ./esp-idf.nix { };
}
