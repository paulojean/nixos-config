# { pkgs ? import <nixpkgs> {}, ... }:
{ pkgs, ... }:
with pkgs;
{
  nord-nm-gui = callPackage ./nord-nm-gui {};
  teiler = callPackage ./teiler {};
}
