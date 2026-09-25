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

  blazeScript = pkgs.writeShellScriptBin "blaze" ''
    set -euo pipefail

    # Everything blaze prints is Stylix base0D blue, always — every
    # named var points at the same color on purpose. Terminal colors
    # untouched, this is blaze output only.
    COLOR_TITLE="${c_base0D}"
    COLOR_BLUE="${c_base0D}"
    COLOR_CYAN="${c_base0D}"
    COLOR_GREEN="${c_base0D}"
    COLOR_YELLOW="${c_base0D}"
    COLOR_RED="${c_base0D}"
    BOLD="${c_bold}"
    NC="${c_reset}"

    FLAKE_DIR="$HOME/.config/nixos"
    HOSTNAME="nixos"

    # Banner: figlet "slant" BLAZE, generated with a temp nix-shell
    # figlet (nothing permanent). echo -e on purpose: the \033 color
    # codes NEED interpreting, and the art charset is clean (no
    # backslashes, no backticks, no $), so there's nothing to mangle.
    # (printf was tried: it prints \033 literally. Never again.)
    print_banner() {
      echo -e "${c_base0D}    ____  __    ___ _____   ______${c_reset}"
      echo -e "${c_base0D}   / __ )/ /   /   /__  /  / ____/${c_reset}"
      echo -e "${c_base0D}  / __  / /   / /| | / /  / __/${c_reset}"
      echo -e "${c_base0D} / /_/ / /___/ ___ |/ /__/ /___${c_reset}"
      echo -e "${c_base0D}/_____/_____/_/  |_/____/_____/${c_reset}"
      echo
    }

    print_help() {
      print_banner
      echo -e "''${BOLD}''${COLOR_BLUE}Commands:''${NC}"
      echo -e "  ''${COLOR_CYAN}rebuild''${NC}           Rebuild and switch to the new system generation"
      echo -e "  ''${COLOR_CYAN}rebuild-boot''${NC}      Rebuild and set as default for next boot"
      echo -e "  ''${COLOR_CYAN}test''${NC}              Build and activate temporarily without boot entry"
      echo -e "  ''${COLOR_CYAN}update''${NC}            Update flake lock inputs and rebuild system"
      echo -e "  ''${COLOR_CYAN}sync''${NC}              Pull remote changes, then rebuild and switch"
      echo -e "  ''${COLOR_CYAN}rollback''${NC}          Roll back to the previous system generation"
      echo -e "  ''${COLOR_CYAN}check''${NC}             Check flake evaluation and dry-run build"
      echo -e "  ''${COLOR_CYAN}diff''${NC}              Show what changed vs the booted generation"
      echo -e "  ''${COLOR_CYAN}status''${NC}            Git status, recent commits, current generation"
      echo -e "  ''${COLOR_CYAN}doctor''${NC}            Sanity checks: git state, disk, failed units"
      echo -e "  ''${COLOR_CYAN}edit''${NC}              Open the flake in \$EDITOR (or a path inside it)"
      echo -e "  ''${COLOR_CYAN}list-gens''${NC}         List system and user generations"
      echo -e "  ''${COLOR_CYAN}cleanup''${NC}           Garbage collect and remove old generations"
      echo -e "  ''${COLOR_CYAN}flatpak-sync''${NC}      Show host vs Flatpak Nvidia, then manual update/prune"
      echo -e "  ''${COLOR_CYAN}help''${NC}              Show this help message"
      echo
      echo -e "''${BOLD}''${COLOR_BLUE}Options:''${NC}"
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

      sync)
        print_banner
        stage_git
        echo -e "''${COLOR_BLUE}==> Pulling remote changes...''${NC}"
        git -C "$FLAKE_DIR" pull --rebase origin master
        echo -e "''${COLOR_GREEN}==> Rebuilding system...''${NC}"
        if command -v nh >/dev/null 2>&1; then
          nh os switch "$FLAKE_DIR" "$@"
        else
          sudo nixos-rebuild switch --flake "$FLAKE_DIR#$HOSTNAME" "$@"
        fi
        echo -e "''${COLOR_GREEN}✔ Synced and rebuilt!''${NC}"
        ;;

      rollback)
        print_banner
        echo -e "''${COLOR_YELLOW}==> Rolling back to the previous generation...''${NC}"
        sudo nixos-rebuild switch --rollback
        echo -e "''${COLOR_GREEN}✔ Rolled back! Reboot if the kernel changed.''${NC}"
        ;;

      check|dry)
        print_banner
        stage_git
        echo -e "''${COLOR_CYAN}==> Evaluating system configuration...''${NC}"
        nix --extra-experimental-features "nix-command flakes" eval "$FLAKE_DIR#nixosConfigurations.$HOSTNAME.config.system.build.toplevel.drvPath"
        echo -e "''${COLOR_GREEN}✔ Flake evaluation succeeded!''${NC}"
        ;;

      diff)
        print_banner
        echo -e "''${COLOR_CYAN}==> Booted generation vs current system...''${NC}"
        nix store diff-closures /run/booted-system /run/current-system || true
        ;;

      status|st)
        print_banner
        echo -e "''${BOLD}''${COLOR_BLUE}=== Git status ===''${NC}"
        git -C "$FLAKE_DIR" status --short || true
        echo
        echo -e "''${BOLD}''${COLOR_BLUE}=== Recent commits ===''${NC}"
        git -C "$FLAKE_DIR" log --oneline -8 || true
        echo
        echo -e "''${BOLD}''${COLOR_BLUE}=== Current generation ===''${NC}"
        nixos-rebuild list-generations 2>/dev/null | head -3 || true
        ;;

      doctor)
        print_banner
        echo -e "''${COLOR_CYAN}==> Doctor is in...''${NC}"
        if [ -n "$(git -C "$FLAKE_DIR" status --porcelain 2>/dev/null)" ]; then
          echo -e "''${COLOR_YELLOW}! Uncommitted changes in the flake''${NC}"
        else
          echo -e "''${COLOR_GREEN}✔ Flake tree clean''${NC}"
        fi
        echo -e "''${COLOR_BLUE}-- Disk --''${NC}"
        df -h /nix/store 2>/dev/null | tail -1 || df -h / | tail -1
        echo -e "''${COLOR_BLUE}-- Failed units --''${NC}"
        if [ -z "$(systemctl --failed --no-legend 2>/dev/null)" ] && [ -z "$(systemctl --user --failed --no-legend 2>/dev/null)" ]; then
          echo -e "''${COLOR_GREEN}✔ No failed units''${NC}"
        else
          systemctl --failed --no-legend 2>/dev/null || true
          systemctl --user --failed --no-legend 2>/dev/null || true
        fi
        ;;

      edit)
        TARGET="''${1:-$FLAKE_DIR}"
        case "$TARGET" in
          /*) ;;
          *) TARGET="$FLAKE_DIR/$TARGET" ;;
        esac
        "''${EDITOR:-nano}" "$TARGET"
        ;;

      list-gens)
        print_banner
        echo -e "''${BOLD}''${COLOR_BLUE}=== System Generations ===''${NC}"
        nix profile history --profile /nix/var/nix/profiles/system || true
        echo
        echo -e "''${BOLD}''${COLOR_BLUE}=== User Generations ===''${NC}"
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

      flatpak-sync)
        print_banner
        echo -e "''${COLOR_BLUE}==> Host Nvidia driver (source of truth)...''${NC}"
        nvidia-smi --query-gpu=driver_version --format=csv,noheader || echo "nvidia-smi not available"
        echo
        echo -e "''${COLOR_BLUE}==> Flatpak Nvidia runtimes installed...''${NC}"
        flatpak list --runtime | grep -i nvidia || echo "No Nvidia runtimes installed"
        echo
        echo -e "''${COLOR_GREEN}==> Running flatpak update (you approve everything, nothing automatic)...''${NC}"
        flatpak update "$@"
        echo -e "''${COLOR_GREEN}==> Pruning unused runtimes (you approve)...''${NC}"
        flatpak uninstall --unused "$@"
        echo -e "''${COLOR_GREEN}✔ Flatpak synced to host driver!''${NC}"
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
    blazeScript
    pkgs.nh
  ];

  programs.nh = {
    enable = true;
    flake = "/home/astrid/.config/nixos";
  };
}
