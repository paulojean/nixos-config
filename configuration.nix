{ config, pkgs, ... }:

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
  hardware.bluetooth.enable = true;
  hardware.bluetooth.extraConfig = "
    [General]
    Enable=Source,Sink,Media,Socket
  ";

  hardware.pulseaudio = {
    enable = true;

    extraModules = [ pkgs.pulseaudio-modules-bt ];

    # NixOS allows either a lightweight build (default) or full build of PulseAudio to be installed.
    # Only the full build has Bluetooth support, so it must be selected here.
    package = pkgs.pulseaudioFull;
  };

  hardware.bumblebee = {
    enable = true;
    pmMethod = "bbswitch";
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

  system.autoUpgrade.enable = true;
  i18n = {
    consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "us";
    defaultLocale = "en_US.UTF-8";
  };

  # Set your time zone.
  time.timeZone = "Europe/Stockholm";

  environment.pathsToLink = [ "/libexec" ];
  environment.systemPackages = with pkgs; [
    albert
    adoptopenjdk-bin
    blueman pulseaudio-modules-bt
    jq killall acpi tlp
    bash wget neovim emacs curl kitty
    bash-completion exa lsd bat ack ag fd gnugrep pstree
    openssl
    usbutils ipad_charge
    firefox bitwarden vlc tmux
    xsel xclip xcape htop sqlite
    git gitAndTools.diff-so-fancy
    docker docker-compose
    lsof pciutils zip unzip unrar bind cacert
    fzf file
    nodejs yarn
    python27Packages.pip python37Packages.pip python3 python
    stack visualvm perl shellcheck
    clojure leiningen boot
    transmission transmission-gtk
    networkmanagerapplet arandr
    openvpn gnome3.networkmanager-openvpn
    i3lock-fancy
    gnumake cmake
    unclutter
    light
    patchelf
    sysstat
    yad
    gettext
    feh
    xdotool
    xorg.xev
    zathura
    spotify
    gimp
    wine winetricks lutris vulkan-tools
    gnutls libinput-gestures libgpgerror
  ];

  programs = {
    bash.enableCompletion = true;
    light.enable = true;
  };

  fonts.fonts = with pkgs; [
    nerdfonts
    powerline-fonts
    font-awesome_5
  ];

  powerManagement.enable = true;
  powerManagement.powertop.enable = true;
  services.tlp.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  services.blueman.enable = true;
  # Enable sound.
  sound.enable = true;

  # Enable the X11 windowing system.
  services.xserver =  {
    enable = true;

    desktopManager.plasma5.enable = true;

    displayManager.sddm = {
      enable = true;
      autoLogin.enable = false;
      autoLogin.user = "paulo";
    };

    windowManager.i3 = {
      enable = true;
      extraPackages = with pkgs; [
        dmenu #application launcher most people use
        i3lock #default i3 screen locker
        i3blocks #if you are planning on using i3blocks over i3status
     ];
    };

    layout = "us";
    xkbVariant = "intl";
    xkbOptions = "eurosign:e, caps:ctrl_modifier";

    videoDrivers = [ "modesetting" ];
  };

  # Enable touchpad support.
  services.xserver.libinput.enable = true;

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
    inactiveOpacity = "0.5";
  };

  security.pam.services.gdm.enableGnomeKeyring = true;
  #security.sudo.extraConfig = ''
  #  %wheel ALL=(ALL) NOPASSWD: ${pkgs.light}/bin/light
  #'';
  security.sudo.extraRules = [
    {
      commands = [
        {
          command = "${pkgs.light}/bin/light";
          options = [ "NOPASSWD" ];
        }
      ];
      groups = [ "wheel" "video" ];
      users = [ "paulo" ];
    }
    {
      commands = [
        {
          command = "/run/current-system/sw/bin/light";
          options = [ "NOPASSWD" ];
        }
      ];
      groups = [ "wheel" "video" ];
      users = [ "paulo" ];
    }
  ];

  services.gnome3.gnome-keyring.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.paulo = {
    isNormalUser = true;
    extraGroups = [ "wheel" "video" "audio" "networkmanager" "kvm" "render" "sddm" "light" ];
  };

  nixpkgs.overlays = [ (self: super: {
    lutris = super.lutris.overrideAttrs (attrs: rec {
      patches = [ ./patches/lutris.patch ];
    });
  })];

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "19.09"; # Did you read the comment?

}
