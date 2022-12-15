{ pkgs, fetchFromGitHub, python3, stdenv, gdb, lib }:

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
  # patched sources
  esp-idf-src = stdenv.mkDerivation {
    name = "esp-idf-src";
    src = fetchFromGitHub {
      owner = "espressif";
      repo = "esp-idf";
      rev = "7edc3e878fc42aecf9606c584ff1122a0ae2059d"; # v4.4.3
      fetchSubmodules = true;
      sha256 = "sha256-37ilQ9w0XDZwVDrodoRowMa9zcDuzBYk1hSSOO8ooXY=";
    };
    patches = [ ./0001-fix-requirements.patch ];
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

  phases = [ "installPhase" ];

  installPhase = ''
    makeWrapper ${python_env}/bin/python $out/bin/idf.py \
    --add-flags ${src}/tools/idf.py \
    --set IDF_PATH ${src} \
    --prefix PATH : "${lib.makeBinPath buildInputs}"
  '';

  shellHook = ''
    export IDF_PATH=${src}
    export PATH=$IDF_PATH/tools:$PATH
    export IDF_PYTHON_ENV_PATH=${python_env}
  '';
}
