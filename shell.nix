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
with (import ./. { });
let
  # idf = esp-idf;
  idf = esp-idf-camera;
in
mkShell {
  name = "esp-idf-env";
  buildInputs = [
    esp32-toolchain
    idf
    idf.python_env

    esptool
  ];
  # shellHook = ''
  #   export IDF_PATH=${idf}/esp-idf
  #   export PATH=$IDF_PATH/tools:$PATH
  #   export PYTHONPATH=${idf.python_env}/${idf.python_env.sitePackages}:$PYTHONPATH
  #   export IDF_PYTHON_ENV_PATH=${idf.python_env}
  # '';
  shellHook = idf.shellHook + ''
    export IDF_PATH=${idf}/esp-idf
  '';
}
