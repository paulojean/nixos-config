{ config, pkgs, ... }:

let
  packages = pkgs.callPackage ./packages { pkgs = pkgs; } ;
  nvidia-offload = pkgs.writeShellScriptBin "nvidia-offload" ''
    export __NV_PRIME_RENDER_OFFLOAD=1
    export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
    export __VK_LAYER_NV_optimus=NVIDIA_only
    exec -a "$0" "$@"
  '';
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./network/hosts.nix
    ];

  nix.gc.automatic = true;
  nix.gc.options = "--delete-older-than 10d";

  nixpkgs.config.allowUnfree = true;

  hardware.cpu.intel.updateMicrocode = true;
  hardware.bluetooth = {
    enable = true;
    settings = {
      General = { Enable = "Source,Sink,Media,Socket"; };
    };
  };

  hardware.pulseaudio = {
    enable = true;

    extraModules = [ pkgs.pulseaudio-modules-bt ];

    # NixOS allows either a lightweight build (default) or full build of PulseAudio to be installed.
    # Only the full build has Bluetooth support, so it must be selected here.
    package = pkgs.pulseaudioFull;
  };

  hardware.nvidia.prime = {
    offload.enable = true;

    # Bus ID of the Intel GPU. You can find it using lspci, either under 3D or VGA
    intelBusId = "PCI:0:2:0";
    # Bus ID of the NVIDIA GPU. You can find it using lspci, either under 3D or VGA
    nvidiaBusId = "PCI:1:0:0";
  };

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelParams = [
    "acpi_osi=!"
    ''acpi_osi="Windows 2009"''

    # avoid hard block on susped
    # https://askubuntu.com/a/1057793
    "quiet splash"

    "intel_pstate=disable"
  ];

  networking.networkmanager.enable = true;

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.enp60s0.useDHCP = true;
  networking.interfaces.wlo1.useDHCP = true;
  networking.enableIPv6 = false;

  system.autoUpgrade.enable = true;
  i18n = {
    defaultLocale = "en_US.UTF-8";
  };

  console.font = "Lat2-Terminus16";
  console.keyMap = "us";

  # Set your time zone.
  time.timeZone = "Europe/Stockholm";

  environment.pathsToLink = [ "/libexec" ];
  environment.systemPackages = with pkgs; [
    albert
    adoptopenjdk-bin
    blueman pulseaudio-modules-bt
    jq killall acpi tlp
    bash wget neovim emacs curl whois kitty
    harfbuzzFull
    # bash-completion
    exa lsd bat ack ag fd gnugrep pstree
    openssl wireshark
    usbutils ipad_charge
    firefox bitwarden vlc tmux
    keynav xsel xclip xcape htop sqlite
    git gitAndTools.diff-so-fancy
    docker-compose
    lsof pciutils zip unzip unrar bind cacert
    fzf file nnn
    libreoffice
    nodejs yarn

    python27Packages.pip python37Packages.pip python3 python

    terraform-lsp

    stack visualvm perl shellcheck
    clojure leiningen boot clojure-lsp
    transmission transmission-gtk
    networkmanagerapplet arandr
    openvpn gnome3.networkmanager-openvpn
    rofi
    gnumake cmake
    entr
    unclutter
    patchelf
    sysstat
    yad
    gettext
    feh
    xdotool
    xorg.xev
    zathura azpainter
    spotify
    gimp
    wine winetricks vulkan-tools
    gnutls libinput-gestures libgpgerror

    polybar
    tabbed
    wmctrl
    dunst

    # - bspwm
    i3lock-fancy
    sxhkd socat
    xorg.xwininfo

    nvidia-offload

    packages.sxhkd-statusd
    packages.teiler

    p7zip
    epsxe

    playonlinux

    # - tmux-fzf
    bc
  ];
  nixpkgs.config.permittedInsecurePackages = [
    "p7zip-16.02"
    "openssl-1.0.2u"
  ];

  programs = {
    # bash.enableCompletion = true;
    light.enable = true;
    steam.enable = true;
  };

  fonts.fonts = with pkgs; [
    nerdfonts
    powerline-fonts
    font-awesome_5
  ];

  powerManagement.enable = true;
  powerManagement.powertop.enable = true;
  services.tlp.enable = true;

  services.usbmuxd.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  services.blueman.enable = true;
  # Enable sound.
  sound.enable = true;

  # Enable the X11 windowing system.
  services.xserver =  {
    enable = true;

    displayManager.autoLogin.enable = false;
    displayManager.lightdm = {
      enable = true;
    };

    displayManager.sessionCommands = ''
      xinput --set-prop "SynPS/2 Synaptics TouchPad" "libinput Accel Speed" 1.0
    '';

    windowManager.i3 = {
      enable = true;
      package = pkgs.i3-gaps;
      extraPackages = with pkgs; [
        dmenu #application launcher most people use
        i3lock #default i3 screen locker
        i3blocks #if you are planning on using i3blocks over i3status
        polybar
     ];
    };

    layout = "us";
    xkbVariant = "intl";
    xkbOptions = "eurosign:e, caps:ctrl_modifier";

    # "displaylink" to make nix recognize HDMI entry
    videoDrivers = [ "displaylink" "modesetting" ];
  };

  # Enable touchpad support.
  services.xserver.libinput.enable = true;

  services.emacs.enable = true;

  services.unclutter = {
    enable = true;
    timeout = 10;
  };

  services.logind.extraConfig = ''
    HandleSuspendKey=hibernate
    HandleLidSwitch=hibernate
  '';

  services.compton = {
    enable = true;
    inactiveOpacity = 0.9;
    opacityRules = [
      "100:class_g = 'Rofi'"
      "100:class_g = 'Firefox'"
    ];
  };

  virtualisation = {
    docker.enable = true;
    podman.enable = true;
  };

  security.pam.services.gdm.enableGnomeKeyring = true;
  security.sudo.extraRules = [
    {
      commands = [
        {
          command = "${pkgs.light}/bin/light";
          options = [ "NOPASSWD" ];
        }
        {
          command = "${pkgs.tlp}/bin/bluetooth";
          options = [ "NOPASSWD" ];
        }
      ];
      groups = [ "wheel" ];
    }
  ];

  services.gnome3.gnome-keyring.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.paulo = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" "video" "audio" "networkmanager" "kvm" "render" "sddm" "lightdm" "light" "usbmux" ];
  };

  nixpkgs.overlays = [ (self: super: {
    # lutris = super.lutris.overrideAttrs (attrs: rec {
    #   patches = [ ./patches/lutris.patch ];
    # });
    polybar = super.polybar.override {
      pulseSupport = true;
      mpdSupport = true;
      # i3Support = true;
      i3GapsSupport = true;
      jsoncpp = super.jsoncpp;
      i3 = super.i3;
    };
  })];

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "20.09"; # Did you read the comment?

}
