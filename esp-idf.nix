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
      fetchSubmodules = true;
      leaveDotGit = true;
      # v4.4.3
      rev = "7edc3e878fc42aecf9606c584ff1122a0ae2059d";
      hash = "sha256-mIGKcgDbCbojPAjWdSCIoENMHSiJ3nvTnoPpgKXz5tI=";
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

  phases = [ "unpackPhase" "installPhase" ];

  installPhase = ''
    mkdir -p $out
    cp -r . $out/esp-idf
    makeWrapper ${python_env}/bin/python $out/bin/idf.py \
    --add-flags $out/esp-idf/tools/idf.py \
    --set IDF_PATH $out/esp-idf \
    --prefix PATH : "${lib.makeBinPath buildInputs}"
  '';

  shellHook = ''
    export PATH=$IDF_PATH/tools:$PATH
    export PYTHONPATH=${python_env}/${python_env.sitePackages}:$PYTHONPATH
    export IDF_PYTHON_ENV_PATH=${python_env}
  '';
}
