{ ... }: {
  services.scx = {
    enable = true;
    scheduler = "scx_lavd";
    # Upstream lavd gaming recipe (scx_loader canonical gaming_mode):
    # --performance = max-perf profile (no core compaction, physical cores
    #   preferred); --pinned-slice-us 500 = 500us slices for latency-critical
    #   tasks instead of the 5000us default. Declarative: survives rebuilds
    #   and flake updates untouched.
    extraArgs = [ "--performance" "--pinned-slice-us" "500" ];
  };
}
