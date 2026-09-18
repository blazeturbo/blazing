# Official Discord client (NOT equibop): force-enable DevTools.
# Discord only honors Ctrl+Shift+I when settings.json contains
# DANGEROUS_ENABLE_DEVTOOLS_ONLY_ENABLE_IF_YOU_KNOW_WHAT_YOURE_DOING=true.
# This merges the key idempotently on every activation: Discord's own
# settings are never touched, and a wiped/missing config gets the key
# recreated. jq is referenced at build time only, never installed.
{ lib, pkgs, ... }:
{
  home.activation.enableDiscordDevTools = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    CFG="$HOME/.config/discord/settings.json"
    KEY="DANGEROUS_ENABLE_DEVTOOLS_ONLY_ENABLE_IF_YOU_KNOW_WHAT_YOURE_DOING"
    mkdir -p "$HOME/.config/discord"
    if [ ! -f "$CFG" ]; then
      printf '{"%s":true}' "$KEY" > "$CFG"
    else
      ${pkgs.jq}/bin/jq --arg k "$KEY" '.[$k] = true' "$CFG" > "$CFG.tmp" \
        && mv "$CFG.tmp" "$CFG" || rm -f "$CFG.tmp"
    fi
  '';
}
