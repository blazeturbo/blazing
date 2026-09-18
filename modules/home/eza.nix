# Eza is a ls replacement with icons and colors
_: {
  programs.eza = {
    enable = true;
    icons = "auto";
    enableBashIntegration = true;
    enableZshIntegration = true;
    git = true;

    extraOptions = [
      "--group-directories-first"
      "--no-quotes"
      "--header"
      "--git-ignore"
      "--icons=always"
      "--classify"
      "--hyperlink"
    ];
  };
  # Aliases to make `ls`, `ll`, `la` use eza
  home.shellAliases = {
    ls = "eza";
    lt = "eza --tree --level=2";
    ll = "eza -lh --no-user --long";
    la = "eza -lah ";
    tree = "eza --tree ";
  };
}
