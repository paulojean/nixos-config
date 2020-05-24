{ pkgs, ... }: with pkgs;
let
  desktopItem = makeDesktopItem {
    name = "NordVPN";
    exec = "nord-vpn";
    comment = "NordVPN client";
    desktopName = "NordVPN";
    genericName = "NordVPN";
    categories = "X-Internet;System;X-Utilities";
  };
in
qt5.mkDerivation rec {
  pname = "nord-vpn";
  version = "1.4.1";

  system = builtins.currentSystem;
  src = fetchFromGitHub {
    owner = "vfosterm";
    repo = "NordVPN-NetworkManager-Gui";
    rev = "06783171f3aaef90b1b7fba9740b0a49d201a7d9";
    sha256 = "04zd46v410xrgc2yv782r28p2afzsr9zslk939bxnx754syw2v3j";
  };

  buildInputs = with pkgs;
  [
    (python37.withPackages (pythonPackages: with pythonPackages; [
      requests
      pyqt5_with_qtwebkit
      qtpy
    ]))
  ];

  patches = [ ./nord-nm-gui-bin-patches.diff ];

  installPhase = ''

    mkdir -p $out/bin $out/icons
    mkdir -p $out/share/applications
    cp nord_nm_gui.py $out/nord-vpn
    cp nordvpnicon.png $out/icons/nordvpnicon.png
    chmod +x $out/nord-vpn

    makeWrapper $out/nord-vpn $out/bin/nord-vpn \
      --set PATH ${stdenv.lib.makeBinPath [qt5.full
                                           networkmanagerapplet
                                           networkmanager
                                          ]}

    wrapProgram $out/bin/nord-vpn \
       --prefix LD_LIBRARY_PATH : "${stdenv.lib.makeLibraryPath [
                                     qt5.full
                                     networkmanagerapplet
                                     networkmanager
                                   ]}"

    cp "${desktopItem}/share/applications/"* $out/share/applications
  '';
}
