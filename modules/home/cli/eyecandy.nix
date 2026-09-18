# Eye-candy launchers. Monochrome gray set on purpose to match the
# reference look: gray tools on dark terminal.
{ ... }: {
  home.shellAliases = {
    # Big centered clock, plain white for max readability on dark
    tty-clock = "tty-clock -s -c -C7";
    # Matrix rain, bold
    cmatrix = "cmatrix -b -C blue";
    # Lava lamp: ONE single flat gray (matches the cava/clock gray),
    # gradient mode with both ends equal so it's uniform, not a gradient.
    lavat = "lavat -g -c 939AA3 -k 939AA3 -G";
  };
}
