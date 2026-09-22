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
    # Floating `latest` — tracks newest driver in nixpkgs-unstable on
    # every `rainbow update`, no manual version/hash bumps.
    # If blazing kernel ever refuses to build it, fall back to `stable`.
    package = config.boot.kernelPackages.nvidiaPackages.latest;
  };
}
