# Blazing: nixpkgs's linux-zen, compiled LOCALLY with our tweaks,
# named "blazing" (uname -r reads <version>-blazing).
#
# How the rename works: nixpkgs's zen recipe hardcodes modDirVersion
# internally, so instead of fighting it we re-run the SAME recipe file
# with a wrapped buildLinux that swaps the name and merges our .config
# deltas on top. Zen's own config (1000Hz, full preempt, NTSYNC, futex,
# tickless) flows through untouched; version/src track nixpkgs, no pins.
{ pkgs, lib, inputs, ... }:
let
  zenFile = "${inputs.nixpkgs}/pkgs/os-specific/linux/kernel/zen-kernels.nix";

  blazingBuildLinux =
    args:
    pkgs.buildLinux (args
      // {
        modDirVersion = "${args.version}-blazing";
        structuredExtraConfig = args.structuredExtraConfig // {
          # -march=native tuning for Alder Lake (i5-12400F).
          # If 7.2 lacks this symbol the config phase fails fast —
          # drop the line, nothing else changes.
          MALDERLAKE = lib.mkForce lib.kernel.yes;
          # Single-socket desktop: no NUMA balancing overhead.
          NUMA = lib.mkForce lib.kernel.no;
        };
      });

  blazingKernel = pkgs.callPackage zenFile { buildLinux = blazingBuildLinux; };
in {
  boot.kernelPackages = pkgs.linuxPackagesFor blazingKernel;

  boot.kernelParams = [
    "mitigations=off" # CPU vuln mitigations off (gaming FPS on Intel)
    "preempt=full" # force full preemption (PREEMPT_DYNAMIC allows it)
    "split_lock_detect=off" # Alder Lake split-lock "misery mode" off (Proton/DXVK stutter fix)
    "transparent_hugepage=always" # THP always (games/Proton over madvise)
    "nowatchdog" # less jitter, zero downside on desktop
  ];

  boot.kernel.sysctl = {
    # Many Proton/Windows games refuse to start below this (Sober too)
    "vm.max_map_count" = 1048576;
    # Runtime half of the split-lock fix (toggleable without reboot)
    "kernel.split_lock_mitigate" = 0;
  };
}
