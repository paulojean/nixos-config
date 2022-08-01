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

    # NixOS allows either a lightweight build (default) or full build of PulseAudio to be installed.
    # Only the full build has Bluetooth support, so it must be selected here.
    package = pkgs.pulseaudioFull;
  };

  # hardware.nvidia.prime = {
  #   offload.enable = true;

  #   # Bus ID of the Intel GPU. You can find it using lspci, either under 3D or VGA
  #   intelBusId = "PCI:0:2:0";
  #   # Bus ID of the NVIDIA GPU. You can find it using lspci, either under 3D or VGA
  #   nvidiaBusId = "PCI:1:0:0";
  # };

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelParams = [
    "acpi_osi=!"
    ''acpi_osi="Windows 2009"''

    # avoid hard block on susped
    # https://askubuntu.com/a/1057793
    "quiet" "splash"

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

  # Fixing IPv6 bug, see https://github.com/NixOS/nixpkgs/issues/87802#issuecomment-628536317
  networking.networkmanager.dispatcherScripts = [{
    source = pkgs.writeText "upHook" ''
      if [ "$2" != "up" ]; then
      logger "exit: event $2 != up"
      exit
      fi
      echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6
    '';
    type = "basic";
  }];

  # chromecastSupport
  networking.firewall.allowedTCPPorts = [
    8010 # chromecastSupport
  ];
  networking.firewall.allowedUDPPortRanges = [ { from = 32768; to = 60999; } ];
  nix = {
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  services.avahi.enable = true;

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
    jdk11 jdk17
    blueman
    jq killall acpi tlp
    bash wget
    neovim vimPlugins.vim-plug
    emacs
    curl whois kitty
    harfbuzzFull
    # bash-completion
    exa lsd bat ack silver-searcher fd gnugrep pstree bottom
    openssl wireshark
    udiskie usbutils ipad_charge
    firefox chromium bitwarden vlc tmux
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
    scala_2_13 sbt
    clojure leiningen boot clojure-lsp babashka
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
    zathura azpainter mcomix3
    spotify
    gimp
    wine winetricks vulkan-tools
    gnutls libinput-gestures libgpgerror

    polybar
    tabbed
    wmctrl
    dunst

    packages.eww
    # eww widgets dependencies
    playerctl
    wirelesstools


    # - bspwm
    i3lock-fancy
    sxhkd socat
    xorg.xwininfo

    # nvidia-offload

    packages.sxhkd-statusd
    packages.teiler
    packages.icons.pokemon-cursor

    p7zip

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
    # steam.enable = true;
  };

  fonts.fonts = with pkgs; [
    nerdfonts
    powerline-fonts
    font-awesome_5
  ];

  powerManagement.enable = true;
  powerManagement.powertop.enable = true;

  services.fstrim.enable = true;
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
    # videoDrivers = [ "displaylink" "modesetting" ];
    videoDrivers = [ "modesetting" ];

    # Enable touchpad support.
    libinput = {
      enable = true;
      touchpad = {
        accelSpeed = "0.9";
        clickMethod = "clickfinger";
        # disableWhileTyping = true;
        # naturalScrolling = true;
        tapping = true;
      };
    };
  };

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

  environment.etc = {
    "modprobe.d/blacklist-nouveau.conf".text = ''
      blacklist nouveau
      options nouveau modeset=0
    '';
  };

  services.udev.extraRules = ''
    # https://wiki.archlinux.org/title/Hybrid_graphics#Using_udev_rules
    # Remove NVIDIA USB xHCI Host Controller devices, if present
    ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x0c0330", ATTR{power/control}="auto", ATTR{remove}="1"
    # Remove NVIDIA USB Type-C UCSI devices, if present
    ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x0c8000", ATTR{power/control}="auto", ATTR{remove}="1"
    # Remove NVIDIA Audio devices, if present
    ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x040300", ATTR{power/control}="auto", ATTR{remove}="1"
    # Remove NVIDIA VGA/3D controller devices
    ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x03[0-9]*", ATTR{power/control}="auto", ATTR{remove}="1"
  '';

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

  services.gnome.gnome-keyring.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.paulo = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" "video" "audio" "networkmanager" "kvm" "render" "sddm" "lightdm" "light" "usbmux" ];
  };

  nixpkgs.overlays = [ (self: super: {
    polybar = super.polybar.override {
      pulseSupport = true;
      mpdSupport = true;
      i3GapsSupport = true;
      jsoncpp = super.jsoncpp;
      i3 = super.i3;
    };
  })];

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "22.05"; # Did you read the comment?

}
