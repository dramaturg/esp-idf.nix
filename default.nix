{ pkgs ? import
    (builtins.fetchGit {
      name = "nixos-22.11-2022_12_12";
      url = "https://github.com/nixos/nixpkgs/";
      ref = "refs/heads/nixos-22.11";
      rev = "dfef2e61107dc19c211ead99a5a61374ad8317f4";
    })
    { }
}:

pkgs.mkShell rec {
  name = "esp-idf-env";
  buildInputs = with pkgs; [
    (pkgs.callPackage ./esp32-toolchain.nix {})
    esptool

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

    (python3.withPackages (p: with p; [
      pip
      virtualenv
      pyserial
    ]))
  ];

  shellHook = ''
    export IDF_PATH=${builtins.toString ./.}/esp-idf
    export PATH=$IDF_PATH/tools:$PATH
    export IDF_PYTHON_ENV_PATH=${builtins.toString ./.}/.python_env

    if [ ! -e $IDF_PYTHON_ENV_PATH ]; then
      python -m venv $IDF_PYTHON_ENV_PATH
      . $IDF_PYTHON_ENV_PATH/bin/activate
      pip install --requirement $IDF_PATH/requirements.txt
    else
      . $IDF_PYTHON_ENV_PATH/bin/activate
    fi
  '';
}

