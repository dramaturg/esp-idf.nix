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
let
  esp-idf = callPackage ./esp-idf.nix { };
in

mkShell rec {
  name = "esp-idf-env";
  buildInputs = with pkgs; [
    (callPackage ./esp32-toolchain.nix { })
    esp-idf
    esp-idf.python_env

    git
    wget
    gnumake

    flex
    bison
    gperf
    pkgconfig

    cmake

    ncurses5

    ninja
  ];

  shellHook = esp-idf.shellHook;
}

