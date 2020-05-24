{ pkgs, ... }: with pkgs;
# with (import <nixpkgs> {}).pkgs;
stdenv.mkDerivation rec {
  pname = "sxhkd-statusd";
  version = "0.0.1";
  src = fetchFromGitHub {
    owner = "piutranq";
    repo = "sxhkd-statusd";
    rev = "2604722b1e76352b934fcc1a00f8345e1121482e";
    sha256 = "16gbrpighlpi49p8yxbhdwm6fl088b1pzdiim5cq7p0iyd0155lz";
  };

  makeFlags = [
    "PREFIX=$(out)/bin/"
  ];
  postInstall = ''
    cp sxhkd-statusd $out/bin/
  '';
}
