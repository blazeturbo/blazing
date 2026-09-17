{ pkgs, ... }:
let
  rainbowScript = pkgs.writeShellScriptBin "rainbow" ''
    set -euo pipefail

    # Terminal Colors
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[0;33m'
    BLUE='\033[0;34m'
    MAGENTA='\033[0;35m'
    CYAN='\033[0;36m'
    BOLD='\033[1m'
    NC='\033[0m'

    FLAKE_DIR="$HOME/.config/nixos"
    HOSTNAME="nixos"

    print_banner() {
      cat << 'EOF'
  ___       _       _                 
 | _ \ __ _(_)_ _  | |__  _____ __ __ 
 |   // _` | | ' \ | '_ \/ _ \ V  V / 
 |_|_\__,_|_|_||_||_.__/\___/\_/\_/  
       NixOS Configuration CLI         
EOF
      echo
    }

    print_help() {
      print_banner
      echo -e "''${BOLD}Usage:''${NC} rainbow <command> [options]"
      echo
      echo -e "''${BOLD}Commands:''${NC}"
      echo -e "  ''${CYAN}rebuild''${NC}           Rebuild and switch to the new system generation"
      echo -e "  ''${CYAN}rebuild-boot''${NC}      Rebuild and set as default for next boot"
      echo -e "  ''${CYAN}test''${NC}              Build and activate temporarily without boot entry"
      echo -e "  ''${CYAN}update''${NC}            Update flake lock inputs and rebuild system"
      echo -e "  ''${CYAN}check''${NC}             Check flake evaluation and dry-run build"
      echo -e "  ''${CYAN}list-gens''${NC}         List system and user generations"
      echo -e "  ''${CYAN}cleanup''${NC}           Garbage collect and remove old generations"
      echo -e "  ''${CYAN}help''${NC}              Show this help message"
      echo
      echo -e "''${BOLD}Options:''${NC}"
      echo -e "  --dry, -n         Show what would be built without executing"
      echo -e "  --ask, -a         Ask for confirmation before proceeding (nh)"
      echo -e "  --verbose, -v     Verbose output"
      echo
    }

    stage_git() {
      if [ -d "$FLAKE_DIR/.git" ]; then
        echo -e "''${BLUE}==> Staging uncommitted changes in git...''${NC}"
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
        echo -e "''${GREEN}==> Rebuilding and switching NixOS generation...''${NC}"
        if command -v nh >/dev/null 2>&1; then
          nh os switch "$FLAKE_DIR" "$@"
        else
          sudo nixos-rebuild switch --flake "$FLAKE_DIR#$HOSTNAME" "$@"
        fi
        echo -e "''${GREEN}✔ Rebuild complete!''${NC}"
        ;;

      rebuild-boot|boot)
        print_banner
        stage_git
        echo -e "''${YELLOW}==> Rebuilding NixOS for next boot...''${NC}"
        if command -v nh >/dev/null 2>&1; then
          nh os boot "$FLAKE_DIR" "$@"
        else
          sudo nixos-rebuild boot --flake "$FLAKE_DIR#$HOSTNAME" "$@"
        fi
        echo -e "''${GREEN}✔ Boot configuration updated!''${NC}"
        ;;

      test)
        print_banner
        stage_git
        echo -e "''${CYAN}==> Testing NixOS configuration...''${NC}"
        if command -v nh >/dev/null 2>&1; then
          nh os test "$FLAKE_DIR" "$@"
        else
          sudo nixos-rebuild test --flake "$FLAKE_DIR#$HOSTNAME" "$@"
        fi
        ;;

      update)
        print_banner
        stage_git
        echo -e "''${MAGENTA}==> Updating flake inputs...''${NC}"
        nix --extra-experimental-features "nix-command flakes" flake update --flake "$FLAKE_DIR"
        stage_git
        echo -e "''${GREEN}==> Rebuilding system with updated inputs...''${NC}"
        if command -v nh >/dev/null 2>&1; then
          nh os switch "$FLAKE_DIR" "$@"
        else
          sudo nixos-rebuild switch --flake "$FLAKE_DIR#$HOSTNAME" "$@"
        fi
        echo -e "''${GREEN}✔ System updated successfully!''${NC}"
        ;;

      check|dry)
        print_banner
        stage_git
        echo -e "''${CYAN}==> Evaluating system configuration...''${NC}"
        nix --extra-experimental-features "nix-command flakes" eval "$FLAKE_DIR#nixosConfigurations.$HOSTNAME.config.system.build.toplevel.drvPath"
        echo -e "''${GREEN}✔ Flake evaluation succeeded!''${NC}"
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
        echo -e "''${YELLOW}==> Cleaning up old generations and running garbage collection...''${NC}"
        if command -v nh >/dev/null 2>&1; then
          nh clean all -v "$@"
        else
          sudo nix-collect-garbage -d
          nix-collect-garbage -d
        fi
        echo -e "''${GREEN}✔ Cleanup finished!''${NC}"
        ;;

      help|--help|-h)
        print_help
        ;;

      *)
        echo -e "''${RED}Error: Unknown command '$COMMAND' ''${NC}" >&2
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
