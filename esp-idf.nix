{ pkgs, fetchFromGitHub, python3, stdenv, lib }:

with pkgs;
let
  mach-nix = import
    (builtins.fetchGit {
      url = "https://github.com/DavHau/mach-nix";
      ref = "refs/tags/3.5.0";
      rev = "7e14360bde07dcae32e5e24f366c83272f52923f";
    })
    { };

  # patched sources
  esp-idf-src = stdenv.mkDerivation {
    name = "esp-idf-src";
    src = fetchFromGitHub {
      owner = "espressif";
      repo = "esp-idf";
      fetchSubmodules = true;
      leaveDotGit = true;
      # v4.4.3
      rev = "6407ecb3f8d2cc07c4c230e7e64f2046af5c86f7";
      hash = "sha256-37ilQ9w0XDZwVDrodoRowMa9zcDuzBYk1hSSOO8ooXY=";
    };
    patches = [
      ./0001-esp-idf-v4.4.3-fix-requirements.patch
    ];
    installPhase = ''
      cp -r . $out
    '';
  };
in
stdenv.mkDerivation rec {
  name = "esp-idf";

  nativeBuildInputs = [ pkgs.makeWrapper ];

  buildInputs = with pkgs; [
    ninja
    cmake
    ccache
    dfu-util
    python_env
  ];

  src = esp-idf-src;

  python_env = mach-nix.mkPython {
    requirements = builtins.readFile "${src}/requirements.txt";
  };

  phases = [
    "unpackPhase"
    "installPhase"
  ];

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
