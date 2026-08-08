#!/usr/bin/env bash
# Dotfiles installer.
#
#   ./setup.sh <device> [--dry-run]
#
# Devices live in their own top-level folder; anything portable lives in
# common/. Each entry below is "repo path -> destination", and installing means
# symlinking the destination back at the repo, so editing a live config edits
# the repo directly and nothing can drift out of sync.
#
# An existing destination that is not already our symlink is moved aside to
# backup/ with a timestamp rather than deleted.
set -uo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP="$DOTFILES/backup/$(date +%Y%m%d-%H%M%S)"
DRY=0

usage() {
    cat <<EOF
usage: $(basename "$0") <device> [--dry-run]

devices:
$(find "$DOTFILES" -maxdepth 1 -mindepth 1 -type d \
    ! -name '.git' ! -name 'common' ! -name 'backup' -printf '  %f\n' | sort)
  common      (installed automatically alongside any device)
EOF
    exit 1
}

[ $# -ge 1 ] || usage
DEVICE="$1"; shift
for a in "$@"; do [ "$a" = "--dry-run" ] && DRY=1; done
[ -d "$DOTFILES/$DEVICE" ] || { echo "unknown device: $DEVICE"; usage; }

link() {
    local src="$DOTFILES/$1" dst="$2"
    dst="${dst/#\~/$HOME}"

    if [ ! -e "$src" ]; then
        printf '  skip (not in repo)  %s\n' "$1"; return
    fi
    if [ -L "$dst" ] && [ "$(readlink -f "$dst")" = "$(readlink -f "$src")" ]; then
        printf '  ok (already linked) %s\n' "${dst/#$HOME/\~}"; return
    fi
    if [ $DRY -eq 1 ]; then
        printf '  would link          %-44s -> %s\n' "${dst/#$HOME/\~}" "$1"; return
    fi

    mkdir -p "$(dirname "$dst")"
    if [ -e "$dst" ] || [ -L "$dst" ]; then
        mkdir -p "$BACKUP/$(dirname "${dst#$HOME/}")"
        mv "$dst" "$BACKUP/${dst#$HOME/}"
        printf '  backed up           %s\n' "${dst/#$HOME/\~}"
    fi
    ln -sfn "$src" "$dst"
    printf '  linked              %-44s -> %s\n' "${dst/#$HOME/\~}" "$1"
}

echo "dotfiles : $DOTFILES"
echo "device   : $DEVICE"
[ $DRY -eq 1 ] && echo "mode     : dry run (nothing will change)"
echo

echo "── common ──"
link common/tmux/.tmux.conf   "~/.tmux.conf"
link common/lvim              "~/.config/lvim"
link common/fish              "~/.config/fish"

echo "── $DEVICE ──"
case "$DEVICE" in
  thinkpad)
    link thinkpad/hyprland    "~/.config/hypr"
    link thinkpad/kitty       "~/.config/kitty"
    link thinkpad/i3          "~/.config/i3"
    link thinkpad/i3status    "~/.config/i3status"
    link thinkpad/picom       "~/.config/picom"
    ;;

  aspire-a515g)
    link aspire-a515g/i3               "~/.config/i3"
    link aspire-a515g/polybar          "~/.config/polybar"
    link aspire-a515g/ghostty          "~/.config/ghostty"
    link aspire-a515g/rofi             "~/.config/rofi"
    link aspire-a515g/rofi-themes      "~/.local/share/rofi/themes"
    link aspire-a515g/picom/picom.conf "~/.config/picom.conf"
    link aspire-a515g/ideavim/ideavimrc "~/.ideavimrc"
    link aspire-a515g/systemd/ollama.service \
                                       "~/.config/systemd/user/ollama.service"
    link aspire-a515g/applications/steam.desktop \
                                       "~/.local/share/applications/steam.desktop"
    link aspire-a515g/wallpapers/catppuccin-mesh.png \
                                       "~/Pictures/wallpapers/catppuccin-mesh.png"

    for s in i3-tasklist i3-cheatsheet i3-powermenu i3-dev-layout \
             i3-wordclock game-mode steam-gpu; do
        link "aspire-a515g/bin/$s" "~/.local/bin/$s"
    done

    # Android Studio's config dir is version-stamped, so resolve it at runtime
    # rather than hardcoding a release that will change on the next update.
    as_dir=$(find "$HOME/.config/Google" -maxdepth 1 -type d \
               -name 'AndroidStudio*' 2>/dev/null | sort | tail -1)
    if [ -n "$as_dir" ]; then
        link aspire-a515g/android-studio/keymaps/VSCode-Vim.xml \
             "$as_dir/keymaps/VSCode-Vim.xml"
    else
        echo "  skip (no Android Studio config dir found)"
    fi

    if [ $DRY -eq 0 ]; then
        # `steam` on PATH must resolve to the offload wrapper; it calls
        # /usr/bin/steam by absolute path, so this cannot recurse.
        ln -sfn "$HOME/.local/bin/steam-gpu" "$HOME/.local/bin/steam"
        echo "  linked              ~/.local/bin/steam -> steam-gpu"
        systemctl --user daemon-reload 2>/dev/null || true
    fi
    ;;
esac

echo
if [ $DRY -eq 1 ]; then
    echo "dry run complete - nothing changed."
else
    [ -d "$BACKUP" ] && echo "replaced files were saved to $BACKUP"
    cat <<'EOF'
done.

Remaining manual steps on a fresh machine (see the device README):
  * system files under <device>/system/ must be copied as root
  * fonts, packages and Android Studio plugins are not tracked here
EOF
fi
