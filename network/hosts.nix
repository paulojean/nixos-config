{ pkgs, ... }:
let
  hosts = pkgs.fetchgit {
    url = "https://github.com/StevenBlack/hosts.git";
    rev = "c85f1986ffb5954a3b6d0368488f53e9059f3c0e";
    sha256 = "0rcbzhhhyckxs5ypm9hhc3cl006jdwfzmc91xixwfqzilx5qqazs";
  };
in
{
  networking.extraHosts = builtins.readFile "${hosts}/hosts";
}
