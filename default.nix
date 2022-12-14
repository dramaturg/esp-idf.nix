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
  mach-nix = import
    (builtins.fetchGit {
      url = "https://github.com/DavHau/mach-nix";
      ref = "refs/tags/3.5.0";
    })
    { };

  filterLine = filter: text: lib.lists.fold
    (lines: next_line: lines + "\n" + next_line)
    ""
    (builtins.filter
      filter
      (lib.strings.splitString "\n" text)
    );

  python_env = mach-nix.mkPython rec {
    requirements =
      filterLine (line: !(lib.strings.hasInfix "file://" line))
      (filterLine (line: !(lib.strings.hasInfix "--only-binary" line))
        (builtins.readFile ./esp-idf/requirements.txt)) + ''
      esptool
      pyserial
    '';
  };
in

pkgs.mkShell rec {
  name = "esp-idf-env";
  buildInputs = with pkgs; [
    (pkgs.callPackage ./esp32-toolchain.nix { })

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

    python_env
  ];

  shellHook = ''
    export IDF_PATH=${builtins.toString ./.}/esp-idf
    export PATH=$IDF_PATH/tools:$PATH
    export IDF_PYTHON_ENV_PATH=${python_env}
  '';
}

