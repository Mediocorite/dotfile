# dotfiles

Per-device configuration, installed by symlinking your home directory back at
this repo. Editing a live config edits the repo directly, so the two can never
drift apart.

```
.
├── common/           portable across every machine (tmux, lvim, fish, scripts)
├── thinkpad/         ThinkPad — Hyprland / i3 / kitty
├── aspire-a515g/     Acer Aspire A515-57G — Xorg + i3 + polybar
└── setup.sh          ./setup.sh <device>
```

## Install

```bash
git clone https://github.com/Mediocorite/dotfile.git ~/.dotfiles
cd ~/.dotfiles
./setup.sh aspire-a515g --dry-run   # show what would change
./setup.sh aspire-a515g
```

`common/` is installed alongside whichever device you name. Anything already
present that isn't already our symlink is moved to `backup/<timestamp>/`
rather than deleted.

## Devices

### `aspire-a515g` — Acer Aspire A515-57G

Linux Mint 22, Xorg, i3. Intel Iris Xe drives the display; the RTX 2050 is
reserved for CUDA and games via PRIME on-demand.

| Path | Installs to | What it is |
|---|---|---|
| `i3/` | `~/.config/i3` | window manager, gaps, keybindings, workspace rules |
| `polybar/` | `~/.config/polybar` | top bar — workspaces, window list, status |
| `ghostty/` | `~/.config/ghostty` | terminal |
| `rofi/`, `rofi-themes/` | `~/.config/rofi`, `~/.local/share/rofi/themes` | launcher, keybinding cheatsheet, power menu |
| `picom/picom.conf` | `~/.config/picom.conf` | compositor, tuned cheap for the iGPU |
| `bin/` | `~/.local/bin/` | helper scripts (see below) |
| `ideavim/ideavimrc` | `~/.ideavimrc` | Vim emulation for Android Studio |
| `android-studio/keymaps/` | version-stamped Studio config dir | IDE-side keymap |
| `systemd/ollama.service` | `~/.config/systemd/user/` | local LLM server |
| `applications/steam.desktop` | `~/.local/share/applications/` | routes Steam through the GPU wrapper |
| `wallpapers/` | `~/Pictures/wallpapers/` | generated background |
| `tools/` | *not installed* | generators, run by hand |
| `system/` | *not installed* | root-owned files, copy manually |

#### Scripts

| Script | Bound to | Purpose |
|---|---|---|
| `i3-tasklist` | polybar module | open windows with per-app icons; event-driven off i3's IPC socket, so it costs nothing idle |
| `i3-cheatsheet` | `Super + /` | keybinding sheet parsed live from the i3 config |
| `i3-powermenu` | `Super + Esc` | lock / suspend / reboot / shut down |
| `i3-dev-layout` | `Super + Shift + I` | Android Studio (2/3) beside Claude (1/3) on workspace 2 |
| `i3-wordclock` | polybar module | the clock, in words |
| `game-mode` | manual | frees VRAM from Ollama, runs a command on the dGPU |
| `steam-gpu` | Steam launcher | every Steam game on the RTX 2050, Ollama paused |

#### Manual steps on a fresh install

These are deliberately **not** automated, because they need root or network:

1. **Packages** — `polybar rofi picom feh playerctl maim brightnessctl ghostty`
2. **Fonts** — JetBrainsMono Nerd Font + Symbols Nerd Font into
   `~/.local/share/fonts`, then `fc-cache -f`
3. **Graphics driver** — copy `system/etc/X11/xorg.conf.d/20-modesetting.conf`
   into place as root and remove any `20-intel.conf`. Without this, Xorg loads
   the legacy `intel` DDX, which speaks only DRI2 and pulls in Mesa's i965 —
   a driver with no Gen12 support — so the desktop silently falls back to
   llvmpipe software rendering. Verify with:
   `glxinfo -B | grep renderer` → should name Iris Xe, not llvmpipe.
4. **Ollama** — install to `~/.local/opt/ollama`, then
   `systemctl --user enable --now ollama`
5. **Android Studio plugins** — IdeaVim, Which-Key, AceJump, IdeaVim-EasyMotion,
   ProxyAI. Note they live in `~/.local/share/Google/AndroidStudio<ver>/`,
   *not* the `~/.config` tree.

### `thinkpad`

The earlier setup: Hyprland (Wayland) plus an i3 fallback, kitty, i3status.
Untouched by the restructure beyond being moved into its own folder.

## Notes

- `common/nvim` is a dangling gitlink — a submodule reference with no
  `.gitmodules`, so it clones as an empty directory. It predates this
  restructure and is kept only so nothing is silently discarded; it can be
  removed with `git rm --cached common/nvim`.
- Android Studio rewrites its own keymap XML on exit, reordering entries and
  stripping comments. That is expected: the symlink means those edits land in
  the repo as a normal diff.
