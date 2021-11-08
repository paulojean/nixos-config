# { pkgs ? import <nixpkgs> {}, ... }: with pkgs;
{ pkgs, ... }: with pkgs;
let
  fenix = import (fetchTarball "https://github.com/nix-community/fenix/archive/main.tar.gz") { };
in
(pkgs.makeRustPlatform {
  inherit (fenix.latest) cargo rustc;
}).buildRustPackage rec {
  pname = "eww";
  version = "0.2.0-master";

  src = fetchFromGitHub {
    owner = "elkowar";
    repo = pname;
    rev = "df29780d2ae33784a21e0f955a70868d7764d820";
    sha256 = "0dg94m27l4cfmzcs6zx1cds6bmlc7ljrip9d20ms1f11gjwwx4x0";
  };

  cargoSha256 = "1c781p4pvliplmjd0wdv30vnp5bqh278y5k3f4fmz7awjz7cawin";

  nativeBuildInputs = [ pkg-config gtk3 ];
  buildInputs = [
    gnome.gtk3
    pango
    lispPackages.cl-cffi-gtk-gdk-pixbuf
    gdk-pixbuf
    cairo
    glibc
    libgcc
  ];
}
