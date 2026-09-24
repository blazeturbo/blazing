My NixOS setup. Niri as the window manager, Dank Material Shell as the bar,
Stylix pulling the whole color scheme out of the wallpaper, one flake
to rebuild all of it.

## Previews

<video src="https://github.com/user-attachments/assets/c126ccc6-ae46-461c-ac81-68036d0e8078" autoplay loop muted playsinline></video>

<video src="https://github.com/user-attachments/assets/724ea25e-4ecf-4859-ae6a-e89ddbb5b706" autoplay loop muted playsinline></video>

## Install

Fresh machine: run `install.sh` as your normal user, not root. It asks
username, hostname, timezone, GPU and boot mode, then clones the repo,
writes `variables.nix`, regenerates the hardware config for your
machine, checks the flake, and rebuilds.

```bash
./install.sh
```

No questions asked, for scripts:

```bash
./install.sh --username astrid --hostname nixos --timezone Europe/Paris \
  --gpu nvidia --boot uefi --yes
```

Needs NixOS with flakes, git and sudo. The installer replaces
`hosts/nixos/hardware-configuration.nix` with yours, so re-add custom
mounts afterwards if you had any. GPU and boot answers get recorded,
but NVIDIA + UEFI is what actually works today.

## Day to day

`rainbow rebuild` to switch, `rainbow test` to try without committing,
`rainbow update` for inputs, `rainbow cleanup` to collect garbage.

Keybinds (Mod = Super): Q terminal, B browser, D column widths,
C close, Shift+S screenshot, Shift+D launcher, N notifications,
Shift+V clipboard.

Bits that live outside the repo: Helium AppImage goes in
`~/Applications` with a desktop file, cursor theme unzipped into
`~/.local/share/icons`, Spotify just wants one login.

## Layout

```text
flake.nix / variables.nix   entrypoint, your settings
hosts/nixos/                system: boot, kernel, nvidia, locale, packages
modules/core/               niri, stylix, scheduler, network, rainbow CLI
modules/home/               kitty, zsh, fastfetch, cava, dms, niri configs
wallpapers/                 Stylix builds the palette from stylixImage
install.sh                  fresh-machine installer
```

## Tiny reminder

Once you rebuild, install.sh will try to compile locally a "custom kernel" (basically linux zen with custom parameters and a different name). You can change that in blazing.nix.
