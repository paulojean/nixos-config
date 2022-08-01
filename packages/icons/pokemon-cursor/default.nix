{ pkgs ? import <nixpkgs> {}, ... }: with pkgs;

stdenv.mkDerivation rec {
  pname = "pokemon-cursor";
  version = "1.0.0";
  src = fetchurl {
    url = "https://github.com/ful1e5/pokemon-cursor/releases/download/v1.0.0/Pokemon.tar.gz";
    sha256 = "0cdw85cpjqw6lb8i321d2pnxby2ab3q8f70b3bs82y29g01500mi";
  };
  propagatedBuildInputs = [ hicolor-icon-theme ];
  buildInputs = [ gnutar ];
  unpackPhase = ''
    tar -xvf $src
  '';
  installPhase = ''
    mkdir -p $out/share/icons
    cp -r Pokemon $out/share/icons/
  '';
}
