{ sources ? import ./nix/sources.nix, pkgs ? import sources.nixpkgs { } }:

with pkgs;
let
  mach-nix = import (sources.mach-nix.outPath) { };

  # patched sources
  esp-idf-src = stdenv.mkDerivation {
    name = "esp-idf-src";
    src = sources.esp-idf.outPath;
    patchPhase = "" + toString (map (p: ''
      mkdir -p ${p.dstDir}
      cp -r ${p.srcDir}/* ${p.dstDir}/
    '') [
      {
        dstDir = "components/esptool_py/esptool";
        srcDir = sources.esptool.outPath;
      }
      {
        dstDir = "components/bt/controller/lib_esp32";
        srcDir = sources.esp32-bt-lib.outPath;
      }
      {
        dstDir =
          "components/bootloader/subproject/components/micro-ecc/micro-ecc";
        srcDir = sources.micro-ecc.outPath;
      }
      {
        dstDir = "components/coap/libcoap";
        srcDir = sources.libcoap.outPath;
      }
      {
        dstDir = "components/nghttp/nghttp2";
        srcDir = sources.nghttp2.outPath;
      }
      {
        dstDir = "components/libsodium/libsodium";
        srcDir = sources.libsodium.outPath;
      }
      {
        dstDir = "components/spiffs/spiffs";
        srcDir = sources.spiffs.outPath;
      }
      {
        dstDir = "components/json/cJSON";
        srcDir = sources.cJSON.outPath;
      }
      {
        dstDir = "components/mbedtls/mbedtls";
        srcDir = sources.mbedtls.outPath;
      }
      {
        dstDir = "components/asio/asio";
        srcDir = sources.asio.outPath;
      }
      {
        dstDir = "components/expat/expat";
        srcDir = sources.libexpat.outPath;
      }
      {
        dstDir = "components/lwip/lwip";
        srcDir = sources.esp-lwip.outPath;
      }
      {
        dstDir = "components/mqtt/esp-mqtt";
        srcDir = sources.esp-mqtt.outPath;
      }
      {
        dstDir = "components/protobuf-c/protobuf-c";
        srcDir = sources.protobuf-c.outPath;
      }
      {
        dstDir = "components/unity/unity";
        srcDir = sources.Unity.outPath;
      }
      {
        dstDir = "examples/build_system/cmake/import_lib/main/lib/tinyxml2";
        srcDir = sources.tinyxml2.outPath;
      }
      {
        dstDir = "components/bt/host/nimble/nimble";
        srcDir = sources.esp-nimble.outPath;
      }
      {
        dstDir = "components/cbor/tinycbor";
        srcDir = sources.tinycbor.outPath;
      }
      {
        dstDir = "components/esp_wifi/lib";
        srcDir = sources.esp32-wifi-lib.outPath;
      }
      {
        dstDir = "components/tinyusb/tinyusb";
        srcDir = sources.tinyusb.outPath;
      }
      {
        dstDir =
          "examples/peripherals/secure_element/atecc608_ecdsa/components/esp-cryptoauthlib";
        srcDir = sources.esp-cryptoauthlib.outPath;
      }
      {
        dstDir = "components/cmock/CMock";
        srcDir = sources.CMock.outPath;
      }
      {
        dstDir = "components/openthread/openthread";
        srcDir = sources.openthread.outPath;
      }
      {
        dstDir = "components/bt/controller/lib_esp32c3_family";
        srcDir = sources.esp32c3-bt-lib.outPath;
      }
      {
        dstDir = "components/esp_phy/lib";
        srcDir = sources.esp-phy-lib.outPath;
      }
      {
        dstDir = "components/openthread/lib";
        srcDir = sources.esp-thread-lib.outPath;
      }
      {
        dstDir = "components/ieee802154/lib";
        srcDir = sources.esp-ieee802154-lib.outPath;
      }
    ]);
    installPhase = ''
      cp -r . $out
    '';
  };
in stdenv.mkDerivation rec {
  name = "esp-idf";

  nativeBuildInputs = [ pkgs.makeWrapper ];

  buildInputs = with pkgs; [ ninja cmake ccache dfu-util python_env ];

  src = esp-idf-src;

  python_env = mach-nix.mkPython {
    requirements = ''
      setuptools

      click
      pyserial
      future

      cryptography

      pyparsing>=2.0.3,<2.4.0
      pyelftools
      idf-component-manager

      gdbgui==0.13.2.0
      pygdbmi<=0.9.0.2
      python-socketio
      jinja2<3.1
      itsdangerous<2.1

      kconfiglib==13.7.1

      reedsolo>=1.5.3,<=1.5.4
      bitstring>=3.1.6,<4
      ecdsa

      construct==2.10.54
    '';
    providers = {
      _default = "nixpkgs,conda,wheel,sdist";
      tomli = "conda";
      python-engineio = "conda";
      requests = "conda";
    };
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
