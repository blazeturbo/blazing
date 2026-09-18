{
  pkgs,
  ...
}: {
  programs.bat = {
    enable = true;
    config = {
      pager = "less -FR";
      style = "full";
      # No theme here on purpose: Stylix owns bat theming.
    };
    extraPackages = with pkgs.bat-extras; [
      batman
      batpipe
      batgrep
    ];
  };
  home.sessionVariables = {
    MANPAGER = "sh -c 'col -bx | bat -l man -p'";
    MANROFFOPT = "-c";
  };
}
