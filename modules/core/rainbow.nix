{ config, pkgs, ... }:
let
  c = config.lib.stylix.colors;
  toAnsi = r: g: b: "\\033[38;2;${r};${g};${b}m";
  c_reset = "\\033[0m";
  c_bold = "\\033[1m";

  c_base0E = toAnsi c.base0E-rgb-r c.base0E-rgb-g c.base0E-rgb-b; # magenta / purple
  c_base0D = toAnsi c.base0D-rgb-r c.base0D-rgb-g c.base0D-rgb-b; # blue
  c_base0C = toAnsi c.base0C-rgb-r c.base0C-rgb-g c.base0C-rgb-b; # cyan
  c_base0B = toAnsi c.base0B-rgb-r c.base0B-rgb-g c.base0B-rgb-b; # green
  c_base0A = toAnsi c.base0A-rgb-r c.base0A-rgb-g c.base0A-rgb-b; # yellow / gold
  c_base08 = toAnsi c.base08-rgb-r c.base08-rgb-g c.base08-rgb-b; # red

  rainbowScript = pkgs.writeShellScriptBin "rainbow" ''
    set -euo pipefail

    # Colors dynamically derived from Stylix wallpaper theme!
    COLOR_TITLE="${c_base0E}"
    COLOR_BLUE="${c_base0D}"
    COLOR_CYAN="${c_base0C}"
    COLOR_GREEN="${c_base0B}"
    COLOR_YELLOW="${c_base0A}"
    COLOR_RED="${c_base08}"
    BOLD="${c_bold}"
    NC="${c_reset}"

    FLAKE_DIR="$HOME/.config/nixos"
    HOSTNAME="nixos"

    print_banner() {
      echo -e "${c_base0E}  ___       _       _                 ${c_reset}"
      echo -e "${c_base0D} | _ \\ __ _(_)_ _  | |__  _____ __ __ ${c_reset}"
      echo -e "${c_base0C} |   // _  | | ' \\ | '_ \\/ _ \\ V  V / ${c_reset}"
      echo -e "${c_base0B} |_|_\\\\__,_|_|_||_||_.__/\\___/\\_/\\_/  ${c_reset}"
      echo
    }

    print_help() {
      print_banner
      echo -e "''${BOLD}Usage:''${NC} rainbow <command> [options]"
      echo
      echo -e "''${BOLD}Commands:''${NC}"
      echo -e "  ''${COLOR_CYAN}rebuild''${NC}           Rebuild and switch to the new system generation"
      echo -e "  ''${COLOR_CYAN}rebuild-boot''${NC}      Rebuild and set as default for next boot"
      echo -e "  ''${COLOR_CYAN}test''${NC}              Build and activate temporarily without boot entry"
      echo -e "  ''${COLOR_CYAN}update''${NC}            Update flake lock inputs and rebuild system"
      echo -e "  ''${COLOR_CYAN}check''${NC}             Check flake evaluation and dry-run build"
      echo -e "  ''${COLOR_CYAN}list-gens''${NC}         List system and user generations"
      echo -e "  ''${COLOR_CYAN}cleanup''${NC}           Garbage collect and remove old generations"
      echo -e "  ''${COLOR_CYAN}help''${NC}              Show this help message"
      echo
      echo -e "''${BOLD}Options:''${NC}"
      echo -e "  --dry, -n         Show what would be built without executing"
      echo -e "  --ask, -a         Ask for confirmation before proceeding (nh)"
      echo -e "  --verbose, -v     Verbose output"
      echo
    }

    stage_git() {
      if [ -d "$FLAKE_DIR/.git" ]; then
        echo -e "''${COLOR_BLUE}==> Staging uncommitted changes in git...''${NC}"
        git -C "$FLAKE_DIR" add -A
      fi
    }

    if [ "$#" -eq 0 ]; then
      print_help
      exit 1
    fi

    COMMAND="$1"
    shift

    case "$COMMAND" in
      rebuild|switch)
        print_banner
        stage_git
        echo -e "''${COLOR_GREEN}==> Rebuilding and switching NixOS generation...''${NC}"
        if command -v nh >/dev/null 2>&1; then
          nh os switch "$FLAKE_DIR" "$@"
        else
          sudo nixos-rebuild switch --flake "$FLAKE_DIR#$HOSTNAME" "$@"
        fi
        echo -e "''${COLOR_GREEN}✔ Rebuild complete!''${NC}"
        ;;

      rebuild-boot|boot)
        print_banner
        stage_git
        echo -e "''${COLOR_YELLOW}==> Rebuilding NixOS for next boot...''${NC}"
        if command -v nh >/dev/null 2>&1; then
          nh os boot "$FLAKE_DIR" "$@"
        else
          sudo nixos-rebuild boot --flake "$FLAKE_DIR#$HOSTNAME" "$@"
        fi
        echo -e "''${COLOR_GREEN}✔ Boot configuration updated!''${NC}"
        ;;

      test)
        print_banner
        stage_git
        echo -e "''${COLOR_CYAN}==> Testing NixOS configuration...''${NC}"
        if command -v nh >/dev/null 2>&1; then
          nh os test "$FLAKE_DIR" "$@"
        else
          sudo nixos-rebuild test --flake "$FLAKE_DIR#$HOSTNAME" "$@"
        fi
        ;;

      update)
        print_banner
        stage_git
        echo -e "''${COLOR_TITLE}==> Updating flake inputs...''${NC}"
        nix --extra-experimental-features "nix-command flakes" flake update --flake "$FLAKE_DIR"
        stage_git
        echo -e "''${COLOR_GREEN}==> Rebuilding system with updated inputs...''${NC}"
        if command -v nh >/dev/null 2>&1; then
          nh os switch "$FLAKE_DIR" "$@"
        else
          sudo nixos-rebuild switch --flake "$FLAKE_DIR#$HOSTNAME" "$@"
        fi
        echo -e "''${COLOR_GREEN}✔ System updated successfully!''${NC}"
        ;;

      check|dry)
        print_banner
        stage_git
        echo -e "''${COLOR_CYAN}==> Evaluating system configuration...''${NC}"
        nix --extra-experimental-features "nix-command flakes" eval "$FLAKE_DIR#nixosConfigurations.$HOSTNAME.config.system.build.toplevel.drvPath"
        echo -e "''${COLOR_GREEN}✔ Flake evaluation succeeded!''${NC}"
        ;;

      list-gens)
        print_banner
        echo -e "''${BOLD}=== System Generations ===''${NC}"
        nix profile history --profile /nix/var/nix/profiles/system || true
        echo
        echo -e "''${BOLD}=== User Generations ===''${NC}"
        nix-env --list-generations || true
        ;;

      cleanup|clean)
        print_banner
        echo -e "''${COLOR_YELLOW}==> Cleaning up old generations and running garbage collection...''${NC}"
        if command -v nh >/dev/null 2>&1; then
          nh clean all -v "$@"
        else
          sudo nix-collect-garbage -d
          nix-collect-garbage -d
        fi
        echo -e "''${COLOR_GREEN}✔ Cleanup finished!''${NC}"
        ;;

      help|--help|-h)
        print_help
        ;;

      *)
        echo -e "''${COLOR_RED}Error: Unknown command '$COMMAND' ''${NC}" >&2
        print_help
        exit 1
        ;;
    esac
  '';
in {
  environment.systemPackages = [
    rainbowScript
    pkgs.nh
  ];

  programs.nh = {
    enable = true;
    flake = "/home/astrid/.config/nixos";
  };
}
