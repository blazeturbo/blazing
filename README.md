My NixOS setup. Niri as the window manager, Noctalia as the bar and launcher,
Stylix generating the whole color scheme from the wallpaper, Home Manager for
everything user-level. One flake, one command to rebuild.

## Layout

```text
~/.config/nixos/
├── flake.nix                 # flake entrypoint (nixos + home-manager + stylix + spicetify-nix)
├── flake.lock
├── variables.nix             # username, hostname, timezone, wallpaper, terminal
├── wallpapers/               # Stylix builds the palette from stylixImage
├── hosts/nixos/              # system config: boot, kernel, nvidia, locale,
│                             # ly login, pipewire, flatpak, input-remapper,
│                             # polkit, appimage support, system packages
└── modules/
    ├── core/                 # niri, nvidia, stylix, scx_lavd scheduler, rainbow CLI
    └── home/                 # per-program home-manager modules:
                              # kitty, zsh, starship, eza, zoxide, bat, btop,
                              # fzf (removed), git, yazi, fastfetch (+fastfetch2),
                              # cava, cliphist, eyecandy aliases, noctalia,
                              # spicetify (stylix-colored Spotify), niri configs
```

Per-day commands come from the `rainbow` script (`modules/core/rainbow.nix`):

```text
rainbow rebuild        rebuild + switch now
rainbow rebuild-boot   rebuild for next boot
rainbow test           try a build without committing to it
rainbow update         update flake inputs, then rebuild
rainbow check          evaluate only
rainbow list-gens      list generations
rainbow cleanup        garbage-collect old generations
```

Keybinds worth knowing (Mod = Super): Mod+Q terminal, Mod+B browser,
Mod+D column widths, Mod+C close, Mod+Shift+S region screenshot (Noctalia),
Mod+Shift+D launcher, Mod+N notifications, Mod+Shift+V clipboard.

## Fresh machine install

You need NixOS installed with flakes enabled, and git.

```bash
git clone https://github.com/blazeturbo/os.git ~/.config/nixos
cd ~/.config/nixos

# Hardware config is machine-specific, regenerate it. Review the diff
# afterwards, keep any custom bits (extra mounts, kernel modules).
sudo nixos-generate-config --show-hardware-config > hosts/nixos/hardware-configuration.nix

# Adjust variables.nix (username, hostname, timezone, wallpaper), then:
sudo nixos-rebuild switch --flake .#nixos
```

After that, daily rebuilds are just `rainbow rebuild`. The script
auto-stages git changes (flakes ignore untracked files), so new files get
picked up without you thinking about it.

A few things live outside the repo on purpose and need manual setup:

- **Helium browser** (AppImage, stays out of the store): drop the
  `helium-*.AppImage` into `~/Applications`, make it executable, and put a
  `helium.desktop` in `~/.local/share/applications` with the icon from
  `~/.local/share/icons/helium.png`. Both files are extracted from the
  AppImage itself with `--appimage-extract`.
- **Cursor theme**: unzip into `~/.local/share/icons/`. The config points
  `XCURSOR_THEME` there; relog after changing it.
- **input-remapper**: open the GUI once, build a preset, tick autoload.
  The daemon + autoload hook are already wired.
- **Spotify**: log in once in the app; theming is declarative.

## Notes

- `fastfetch2` is areofyl/fetch vendored under
  `modules/home/fastfetch/fetch-src`, with one small patch: when
  `~/.config/fetch/config` sets `info_command`, the info panel comes from
  that command (`fastfetch --logo none`, i.e. your fastfetch modules)
  instead of its native gatherers. Spinning logo engine untouched.
- The overview backdrop is a second wallpaper layer: `swww`/`awww` serves a
  blurred copy of the wallpaper (derived at build time from `stylixImage`)
  into Niri's backdrop via a layer rule. Change wallpaper, rebuild, blur
  follows. Verify with `niri msg layers`.
- Niri configs validate with `niri validate` before they ever reach your
  session; flake state with `nix flake check --no-build`.
