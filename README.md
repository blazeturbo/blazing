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

Use `install.sh`, it does the boring parts for you: clones the repo to
`~/.config/nixos`, asks a few questions, writes the answers into
`variables.nix`, regenerates `hardware-configuration.nix` for your own
hardware, checks the flake evaluates, then rebuilds into the new system.

You need NixOS with flakes, plus git and sudo. Run it as your normal
user, not root:

```bash
./install.sh
```

With no flags it just walks you through it: username, hostname,
timezone, GPU (nvidia/amd/intel), boot mode (uefi/bios, plus the disk
for grub on BIOS). Everything shows its default in brackets, hitting
enter accepts it, and it re-asks instead of accepting nonsense. At the
end it prints a summary and asks for confirmation before touching
anything.

Full run with no questions asked (for scripts, or if you already know
your answers):

```bash
./install.sh --username astrid --hostname nixos --timezone Europe/Paris \
  --gpu nvidia --boot uefi --yes
```

All the flags: `--repo URL` (if you forked this), `--dir PATH` (clone
somewhere else), `--username NAME`, `--hostname NAME`,
`--timezone ZONE`, `--gpu nvidia|amd|intel`, `--boot uefi|bios`,
`--disk /dev/sda` (BIOS only), `--yes` (skip the confirmation),
`--no-switch` (set everything up but don't rebuild yet), `-h`.

Two honest caveats. First, the installer overwrites
`hosts/nixos/hardware-configuration.nix` with a freshly generated one.
That's on purpose, a hardware config from another machine is useless at
best. If you had custom mounts or kernel modules in there, re-add them
afterwards and rebuild again. Second, the GPU and boot answers are
recorded into `variables.nix`, but the repo currently assumes NVIDIA +
UEFI no matter what you answer — per-GPU module switching and the grub
path land next. On AMD/Intel or BIOS hardware, expect to finish the job
by hand for now.

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
- **Spicetify**: log in once in the app; theming is declarative.

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
