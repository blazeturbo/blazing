{ ... }: {
  services.scx = {
    enable = true;
    scheduler = "scx_lavd";
    # Back on lavd gaming recipe (scx_loader canonical gaming_mode):
    # --performance = max-perf profile (no core compaction, physical cores
    #   preferred); --pinned-slice-us 500 = 500us slices for latency-critical
    #   tasks instead of the 5000us default. Declarative: survives rebuilds
    #   and flake updates untouched.
    # flash (defaults) was tried 2026-09-29 per Aug 2026 bench data — no
    # real-world delta on this box, see git history. Revert is one line.
    extraArgs = [ "--performance" "--pinned-slice-us" "500" ];
  };
}
