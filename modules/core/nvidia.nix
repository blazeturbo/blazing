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
    # The flatpak service (flatpak-nvidia-match in hosts/nixos) reads the
    # LIVE host version at boot and installs that exact GL/Vulkan runtime,
    # so the two sides can never drift apart again no matter how often
    # `latest` moves. If a brand-new driver has no Flathub runtime yet,
    # the service logs it and flatpak picks it up on update once published.
    package = config.boot.kernelPackages.nvidiaPackages.latest;
  };
}
