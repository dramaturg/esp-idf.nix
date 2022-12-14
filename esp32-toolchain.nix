{ stdenv, lib, fetchurl, makeWrapper, buildFHSUserEnv }:

let
  fhsEnv = buildFHSUserEnv {
    name = "esp32-toolchain-env";
    targetPkgs = pkgs: with pkgs; [ zlib ];
    runScript = "";
  };
in

stdenv.mkDerivation rec {
  pname = "crosstool-NG";

  # # for ESP-IDF v4.1-dev
  # version = "2019r2";
  # gcc_version = "8_2_0";
  # hash = "sha256-5tR8Hb2MjL/jcnHl4qrFPuiMnjR66TfiK/DHP1MO+98=";

  # # for ESP-IDF v4.3
  # version = "2020r3";
  # gcc_version = "8_4_0";
  # hash = "sha256-Z0CAoS+cXr5aOlzlHG3q7/5t+wbWQWIz34byW1dOknk=";

  # for ESP-IDF v4.4.3
  version = "2021r2-patch5";
  gcc_version = "8_4_0";
  hash = "sha256-jvFOBAnCARtB5QSjD3DT41KHMTp5XR8kYq0s0OIFLTc=";

  src = fetchurl {
    url = "https://github.com/espressif/${pname}/releases/download/esp-${version}/xtensa-esp32-elf-gcc${gcc_version}-esp-${version}-linux-amd64.tar.gz";
    inherit hash;
  };

  buildInputs = [ makeWrapper ];

  phases = [ "unpackPhase" "installPhase" ];

  installPhase = ''
    cp -r . $out
    for FILE in $(ls $out/bin); do
      FILE_PATH="$out/bin/$FILE"
      if [[ -x $FILE_PATH ]]; then
        mv $FILE_PATH $FILE_PATH-unwrapped
        makeWrapper ${fhsEnv}/bin/esp32-toolchain-env $FILE_PATH --add-flags "$FILE_PATH-unwrapped"
      fi
    done
  '';

  meta = with lib; {
    description = "ESP32 toolchain";
    homepage = https://docs.espressif.com/projects/esp-idf/en/stable/get-started/linux-setup.html;
    license = licenses.gpl3;
  };
}

