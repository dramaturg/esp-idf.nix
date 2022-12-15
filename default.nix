{ pkgs ? import
    (builtins.fetchGit {
      name = "nixos-22.11-2022_12_15";
      url = "https://github.com/nixos/nixpkgs/";
      ref = "refs/heads/nixos-22.11";
      rev = "170e39462b516bd1475ce9184f7bb93106d27c59";
    })
    { }
}:

with pkgs;
let
  # we only need this submodule for ESP32
  esp32-camera = fetchFromGitHub {
    owner = "espressif";
    repo = "esp32-camera";
    rev = "093688e"; # v2.0.1
    sha256 = "sha256-d1MLpibNp90h9cZu2BOij7ywTXqASbTuf3jQ/IuvNGg="; # v2.0.1
    # rev = "402b811b835cd348343b567a97fdf984c9d16fb9";
    # sha256 = "sha256-XItxmpXXRgv11LcnL7dty6uq1JctGokHCU8UGG9ic04=";
  };
in
rec {
  esp32-toolchain = callPackage ./esp32-toolchain.nix { };

  esp-idf = callPackage ./esp-idf.nix { };

  esp-idf-camera = esp-idf.overrideAttrs(old: {
    # phases = old.phases ++ [ "unpackPhase" "patchPhase" ];
    installPhase = old.installPhase + ''
      ln -s ${esp32-camera} $out/esp-idf/components/esp32-camera
    '';
  });
}
