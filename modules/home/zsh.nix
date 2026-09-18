# ZSH shell with Oh My Zsh, autosuggestions, syntax highlighting, and Starship prompt
{ ... }: {
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting = {
      enable = true;
      highlighters = ["main" "brackets" "pattern" "regexp" "root" "line"];
    };
    historySubstringSearch.enable = true;

    history = {
      ignoreDups = true;
      save = 10000;
      size = 10000;
    };

    oh-my-zsh = {
      enable = true;
    };

    initContent = ''
      bindkey "\eh" backward-word
      bindkey "\ej" down-line-or-history
      bindkey "\ek" up-line-or-history
      bindkey "\el" forward-word
    '';

    shellAliases = {
      sv = "sudo nvim";
      v = "nvim";
      c = "clear";
      rr = "rainbow rebuild";
      rc = "rainbow check";
      ru = "rainbow update";
      ncg = "nix-collect-garbage --delete-old && sudo nix-collect-garbage -d && sudo /run/current-system/bin/switch-to-configuration boot";
      cat = "bat";
      man = "batman";
      ".." = "cd ..";
    };
  };
}
