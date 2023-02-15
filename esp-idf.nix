{ sources ? import ./nix/sources.nix, pkgs ? import sources.nixpkgs { }
, fetchFromGitHub, python3, stdenv, lib }:

with pkgs;
let
  mach-nix = import sources.mach-nix { python = "python310"; };
  # patched sources
  esp-idf-src = stdenv.mkDerivation {
    name = "esp-idf-src";
    src = sources.esp-idf.outPath;
    patches = [ ./0001-esp-idf-v4.4.4-fix-requirements.patch ];
    installPhase = ''
      cp -r . $out
    '';
  };
in stdenv.mkDerivation rec {
  name = "esp-idf";
  version = sources.esp-idf.version;

  nativeBuildInputs = with pkgs; [ makeWrapper ];

  buildInputs = with pkgs; [ ninja cmake ccache dfu-util python_env ];

  src = esp-idf-src;

  python_env = mach-nix.mkPython {
    python = "python310";
    requirements = builtins.readFile "${esp-idf-src}/requirements.txt";
    providers = { _default = "nixpkgs,sdist"; };
  };

  phases = [ "unpackPhase" "installPhase" ];

  installPhase = ''
    mkdir -p $out
    cp -r . $out/esp-idf
    makeWrapper ${python_env}/bin/python $out/bin/idf.py \
    --add-flags $out/esp-idf/tools/idf.py \
    --set IDF_PATH $out/esp-idf/ \
    --prefix PATH : "${lib.makeBinPath buildInputs}"
  '';

  shellHook = ''
    export PYTHONPATH=${python_env}/${python_env.sitePackages}:$PYTHONPATH
    export IDF_PYTHON_ENV_PATH=${python_env}
  '';
}
