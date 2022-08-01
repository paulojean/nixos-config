# { pkgs ? import <nixpkgs> {}, ... }:
{ pkgs, ... }:
with pkgs;
{
  nord-vpn = callPackage ./nord-vpn {};
  sxhkd-statusd = callPackage ./sxhkd-statusd {};
  teiler = callPackage ./teiler {};
  eww = callPackage ./eww {};
  icons = {
    pokemon-cursor = callPackage ./icons/pokemon-cursor {};
  };
}
