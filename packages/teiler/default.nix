{ pkgs, ... }: with pkgs;
stdenv.mkDerivation rec {
  pname = "teiler";
  version = "3.1.2";
  src = fetchFromGitHub {
    owner = "carnager";
    repo = "teiler";
    rev = "326510f104020923bf64beb1dc28fe337bc16701";
    sha256 = "1vvdxlni901qsd6vay7r8jdx7l5m75rjj3mfr4pm8fdix88vl5fr";
  };
  buildInputs = with pkgs;
  [
    ffmpeg maim copyq slop rofi xclip
  ];
  patchPhase = ''
    ls -lah
    rm Makefile
    sed -i -e 's# maim # ${maim}/bin/maim #g' teiler
  '';
  installPhase = ''
    mkdir -p $out/bin
    cp teiler $out/bin
    cp teiler_helper $out/bin
  '';
}
