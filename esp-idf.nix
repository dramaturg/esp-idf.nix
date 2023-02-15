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
      fetchSubmodules = false;
      # v4.4.4
      rev = "dab3f38f0f966437c95e35f2c27e20d9a2a18fe7";
      hash = "sha256-9ACFrqK41NUnKWDnT4tM2s4MAwAcrOcQIp8I3uv0aM0=";
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
