# NixOS Flake Configuration

A modern, declarative NixOS configuration powered by **Niri**, **Stylix**, **Noctalia**, and **Home Manager**.

---

## 🧭 Repository Structure

```text
~/.config/nixos/
├── flake.nix                                # Root Flake entrypoint (NixOS + Home Manager + Stylix)
├── flake.lock                               # Locked flake dependencies
├── variables.nix                            # Centralized variables (wallpaper, fonts, user)
├── README.md                                # This documentation guide
├── wallpapers/                              # Wallpapers for Stylix palette generation
│   ├── Rainnight.jpg                        # Active default wallpaper
│   ├── AnimeGirlNightSky.jpg
│   └── mountainscapedark.jpg
├── hosts/
│   └── nixos/
│       ├── default.nix                      # System-level config (boot, networking, users, services)
│       └── hardware-configuration.nix       # Detected system hardware
└── modules/
    ├── core/                                # NixOS system modules
    │   ├── niri.nix                         # Niri window manager & xwayland-satellite
    │   ├── nvidia.nix                       # NVIDIA GeForce RTX 4060 Ti drivers
    │   ├── rainbow.nix                      # 'rainbow' system CLI tool
    │   ├── scheduler.nix                    # sched-ext scx_lavd scheduler
    │   └── stylix.nix                       # Base16 system theming
    └── home/                                # User Home Manager modules
        ├── default.nix                      # Home Manager imports
        ├── kitty.nix                        # Kitty terminal emulator
        ├── noctalia.nix                     # Noctalia bar, launcher & user service
        ├── starship.nix                     # Starship prompt (Stylix themed)
        ├── fastfetch/                       # Fastfetch with NixOS branding
        ├── yazi/                            # Yazi file manager (plugins, flavors, keymaps)
        ├── stylix.nix                       # Home Manager Stylix target overrides
        └── niri/                            # Niri WM configurations (from Hakuspace)
            ├── default.nix                  # Links configs to ~/.config/niri
            ├── animations.kdl               # Hakuspace iris shaders & curves
            ├── autostart.kdl                # Autostart daemons & Noctalia
            ├── config.kdl                   # Root Niri configuration
            ├── environment.kdl              # Wayland & NVIDIA graphics env
            ├── keybinds.kdl                 # Window manager keybindings
            ├── rules.kdl                    # Window rules & transparency
            └── settings.kdl                 # Layout, gaps, shadows, focus ring
```

---

## 🎨 How Theming & Stylix Work

The entire desktop appearance is unified using **Stylix**:
1. Open [`variables.nix`](./variables.nix).
2. Change `stylixImage` to point to any image in [`wallpapers/`](./wallpapers/):
   ```nix
   stylixImage = ./wallpapers/AnimeGirlNightSky.jpg;
   ```
3. Run `rainbow rebuild`.
4. Stylix extracts a 16-color Base16 palette from the image and applies it across:
   - **Kitty** terminal background, foreground, and ANSI colors
   - **Starship** prompt accents and badges
   - **Fastfetch** system information keys
   - **GTK** and **Qt** application themes
   - **Bibata-Modern-Ice** cursors and **JetBrains Mono** font

---

## 🚀 `rainbow` System Management CLI

Just like ZaneyOS provides `zcli`, this configuration includes `rainbow` for quick system management.

| Command | Description |
| :--- | :--- |
| `rainbow rebuild` | Rebuilds configuration and immediately switches to the new generation |
| `rainbow rebuild-boot` | Rebuilds and sets the new generation as default for the next boot |
| `rainbow test` | Builds and activates the configuration temporarily (no boot entry) |
| `rainbow update` | Updates all flake inputs (`nix flake update`) and rebuilds |
| `rainbow check` | Evaluates and verifies the flake without building derivations |
| `rainbow list-gens` | Lists system and user generation history |
| `rainbow cleanup` | Runs garbage collection and removes old generations |
| `rainbow help` | Displays help message and CLI options |

> **Flags:** You can pass `--dry` (or `-n`), `--ask` (or `-a`), and `--verbose` (`-v`) to any rebuild command.

---

## ⌨️ Keybindings Cheat Sheet (Niri)

| Shortcut | Action |
| :--- | :--- |
| <kbd>Mod</kbd> + <kbd>Shift</kbd> + <kbd>D</kbd> | **Noctalia Application Launcher** |
| <kbd>Mod</kbd> + <kbd>Q</kbd> / <kbd>Return</kbd> | Open Kitty Terminal |
| <kbd>Mod</kbd> + <kbd>B</kbd> | Open Firefox |
| <kbd>Mod</kbd> + <kbd>E</kbd> | Open File Manager |
| <kbd>Mod</kbd> + <kbd>N</kbd> | Noctalia Notifications / Control Center |
| <kbd>Mod</kbd> + <kbd>Shift</kbd> + <kbd>V</kbd> | Noctalia Clipboard History |
| <kbd>Mod</kbd> + <kbd>Shift</kbd> + <kbd>,</kbd> | Noctalia Settings |
| <kbd>Mod</kbd> + <kbd>C</kbd> | Close Active Window |
| <kbd>Mod</kbd> + <kbd>F</kbd> | Maximize Column |
| <kbd>Mod</kbd> + <kbd>Shift</kbd> + <kbd>F</kbd> | Fullscreen Window |
| <kbd>Mod</kbd> + <kbd>Z</kbd> | Toggle Window Floating |
| <kbd>Mod</kbd> + <kbd>`</kbd> (tilde) | Toggle Overview |
| <kbd>Mod</kbd> + <kbd>D</kbd> | Cycle Preset Column Widths (50% / 65% / 80% / 100%) |
| <kbd>Mod</kbd> + <kbd>←</kbd> / <kbd>→</kbd> / <kbd>A</kbd> / <kbd>D</kbd> | Focus Left / Right Column |
| <kbd>Print</kbd> / <kbd>Mod</kbd> + <kbd>P</kbd> | Screenshot interactive area |
| <kbd>Mod</kbd> + <kbd>Shift</kbd> + <kbd>E</kbd> | Quit Niri |

*(<kbd>Mod</kbd> is the Super / Windows key)*

---

## ⚡ Additional Features

- **Kernel & Scheduler**: Running latest Linux kernel with the sched-ext `scx_lavd` gaming & latency-optimized scheduler.
- **Hardware Graphics**: Full proprietary NVIDIA driver support for the GeForce RTX 4060 Ti with Wayland GBM backends.
- **CLI Tools**: Yazi file manager with custom plugins and flavors, Starship prompt, and Fastfetch with NixOS styling.
