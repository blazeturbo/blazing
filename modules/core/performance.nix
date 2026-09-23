# Performance mode: all max-perf tweaks behind `vars.performanceMode`.
# Toggle in variables.nix. No kernel rebuild: boot flags, sysctl,
# services and X config only — blazing.nix stays untouched.
#
# Tailored to this box: i5-12400F (6P Alder Lake, intel_pstate/HWP) +
# RTX 4060 Ti (Ada, open kernel module, 160W board) on Niri/Wayland.
{ config, pkgs, lib, ... }:
let
  vars = import ../../variables.nix;
in {
  config = lib.mkIf vars.performanceMode {
    # CPU: always max. intel_pstate `performance` locks EPP to
    # performance in hardware (writes to energy_performance_preference
    # get rejected in this mode — that's the kernel telling you it's
    # already maxed, per kernel.org intel_pstate docs).
    powerManagement.cpuFreqGovernor = "performance";

    # Shallow idle states only: no deep C-state parking latency.
    # Boot flag only, no kernel compile.
    # NOTE: tried forcing max GPU clocks via
    # nvidia.NVreg_RegistryDwords=PowerMizerEnable=0x1;PerfLevelSrc=0x2222
    # here — it applied (mem pegged at 9001, idle power 4x) but FPS didn't
    # move, so it got ripped back out. Just wasted heat. Not trying again.
    boot.kernelParams = [
      "intel_idle.max_cstate=1" # C1 only, skip deep C6 sleep states
      "processor.max_cstate=1" # same guard for acpi_idle fallback
    ];

    # Belt + suspenders: pin EPP to performance on every CPU at boot
    # (no-op once governor=performance locks it — harmless).
    services.udev.extraRules = ''
      ACTION=="add", SUBSYSTEM=="cpu", ATTR{cpufreq/energy_performance_preference}="performance"
    '';

    # Make sure no power-saver daemon fights the governor.
    services.thermald.enable = lib.mkForce false;
    services.tlp.enable = lib.mkForce false;
    services.power-profiles-daemon.enable = lib.mkForce false;
    services.auto-cpufreq.enable = lib.mkForce false;
    powerManagement.powertop.enable = false;

    # Turbo stays on (0 = enabled). Some BIOSes/playbooks leave
    # no_turbo=1 around; force it off every boot.
    systemd.services.enable-turbo = {
      description = "Force Intel turbo boost on (performanceMode)";
      wantedBy = [ "multi-user.target" ];
      serviceConfig.Type = "oneshot";
      script = ''
        echo 0 > /sys/devices/system/cpu/intel_pstate/no_turbo 2>/dev/null || true
        echo 1 > /sys/devices/system/cpu/intel_pstate/hwp_dynamic_boost 2>/dev/null || true
      '';
    };

    # Low-latency sysctl (CFS knobs; harmless under scx_lavd which
    # bypasses CFS — scheduler itself lives in scheduler.nix).
    boot.kernel.sysctl = {
      "kernel.sched_migration_cost_ns" = 500000;
      "kernel.sched_min_granularity_ns" = 1000000;
      "kernel.sched_wakeup_granularity_ns" = 15000000;
    };

    # GPU: unlock OC controls (Coolbits 12 = clock offset + fan, NO
    # overvoltage bit 16 — volts stay stock). Xorg config snippet only.
    # NOTE (honest Wayland caveat): nvidia-settings clock/VRAM offsets
    # only apply from an NVIDIA-driven Xorg session. On Niri/Wayland
    # the driver ignores them — the service below still sets
    # PowerMizer-max + power limit, which DO apply on Wayland. If you
    # ever want the +VRAM to actually stick, log into an Xorg session
    # (or TTY + startx) once with this file present.
    environment.etc."X11/xorg.conf.d/20-nvidia-coolbits.conf".text = ''
      Section "Device"
          Identifier "Nvidia Card"
          Driver "nvidia"
          Option "Coolbits" "12"
      EndSection
    '';

    # GPU: max stock power + tiny VRAM OC, no volts, no core OC.
    # 4060 Ti board is 160W — this just pins it there instead of
    # letting it sag to ~50W at idle/mid load, then tries a
    # conservative +500 MHz mem-transfer offset (+50 core, small).
    # nvidia-settings parts fail silently on pure Wayland (logged),
    # nvidia-smi parts always apply. Runs at boot + graphical session.
    systemd.services.nvidia-max-perf = {
      description = "Pin RTX 4060 Ti to max stock power + tiny VRAM OC (performanceMode)";
      wantedBy = [ "multi-user.target" ];
      after = [ "nvidia-persistenced.service" ];
      path = with pkgs; [ config.hardware.nvidia.package.bin kmod ];
      script = ''
        # Keep driver loaded so clocks don't collapse at idle
        nvidia-smi -pm 1 >>/var/log/nvidia-max-perf.log 2>&1 || true
        # Pin to board max (160W on this 4060 Ti), never above stock
        nvidia-smi -pl 160 >>/var/log/nvidia-max-perf.log 2>&1 || true
        # Max-perf PowerMizer (0=Adaptive broken low, 1=Prefer Max)
        ${config.hardware.nvidia.package.settings}/bin/nvidia-settings \
          -a '[gpu:0]/GpuPowerMizerMode=1' >>/var/log/nvidia-max-perf.log 2>&1 || true
        # TINY OC, VRAM-focused, no voltage: +500 mem transfer, +50 core.
        # No-ops on Wayland (needs Xorg Coolbits session) — safe to retry.
        ${config.hardware.nvidia.package.settings}/bin/nvidia-settings \
          -a '[gpu:0]/GPUMemoryTransferRateOffsetAllPerformanceLevels=500' \
          -a '[gpu:0]/GPUGraphicsClockOffsetAllPerformanceLevels=50' \
          >>/var/log/nvidia-max-perf.log 2>&1 || true
      '';
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
    };
  };
}
