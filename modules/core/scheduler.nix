{ ... }: {
  services.scx = {
    enable = true;
    scheduler = "scx_flash";
    # scx_flash defaults (slice 700us, lag 20000, idle-resume 32) — no
    # extraArgs on purpose. Evidence over vibes:
    # - Aug 2026 Intel Cyberpunk/Starfield bench (GamingOnLinux): flash top
    #   avg FPS, all scx > EEVDF; lavd best 1% lows, flash best avg.
    # - lavd canonical gaming_mode (--performance --pinned-slice-us 500)
    #   was correct but deltas are 0.3-2%, not the 40% drop here.
    # - flash EDF (vruntime + exec_vruntime) feeds GPU with less idle +
    #   less CPU than lavd under load — fits 12400F + background browser.
    # Previous: lavd --performance --pinned-slice-us 500 (kept in git).
    extraArgs = [ ];
  };
}
