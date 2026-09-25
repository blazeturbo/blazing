{ config, pkgs, ... }: {
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    powerManagement.finegrained = false;
    open = true;
    nvidiaSettings = true;
    # Floating `latest` — always the newest driver in nixpkgs-unstable.
    # NixOS is the source of truth for the driver version. Flatpak never
    # decides it: after `blaze update` + reboot, run `blaze flatpak-sync`
    # (or plain `flatpak update`) to fetch the matching GL/Vulkan runtime.
    # If a brand-new driver has no Flathub runtime yet, flatpak keeps the
    # old one until Flathub publishes it — then the next manual sync picks
    # it up.
    package = config.boot.kernelPackages.nvidiaPackages.latest;
  };
}
