{ pkgs, ... }:
let
  hosts = pkgs.fetchgit {
    url = "https://github.com/StevenBlack/hosts.git";
    rev = "1a2e8765cc7ebb2f484c697b0677ab7882d2ae20";
    sha256 = "0n7y3wla3pk85y7z8x2l4kfh7cck1qnrsh6d9vff1dk2mwvh897l";
  };
in
{
  networking.extraHosts = builtins.readFile "${hosts}/hosts";
}
