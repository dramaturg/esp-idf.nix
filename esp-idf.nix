{ sources ? import ./nix/sources.nix, pkgs ? import sources.nixpkgs { }
, fetchFromGitHub, python3, stdenv, lib }:

with pkgs;
let
  mach-nix = import sources.mach-nix {
    pkgs = pkgs;
    pypiDataRev = sources.pypi-deps-db.rev;
    pypiDataSha256 = sources.pypi-deps-db.sha256;
  };
in stdenv.mkDerivation rec {
  name = "esp-idf";
  version = sources.esp-idf.version;

  nativeBuildInputs = [ pkgs.makeWrapper ];

  buildInputs = with pkgs; [ ninja cmake ccache dfu-util python_env ];

  #src = esp-idf-src;
  src = sources.esp-idf.outPath;

  python_env = mach-nix.mkPython {
    requirements = builtins.readFile "${src}/requirements.txt";
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
