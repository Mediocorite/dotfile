#!/usr/bin/env bash

# Define a function for creating symlinks
create_symlink() {
  local source=$1
  local target=$2
  local dotfiles=$3
  local target_name=$(basename "$target")

  # Check if the target exists
  if [ -e "$target" ] || [ -L "$target" ]; then
    # If the target is not already in dotfiles
    if [[ ! "$target" == "$dotfiles/"* ]]; then
      # If dotfiles doesn't already have a folder with the same name, move it there
      if [ ! -e "$dotfiles/$target_name" ]; then
        echo "Moving $target to $dotfiles/$target_name"
        mkdir -p "$dotfiles/$target_name"
        mv "$target" "$dotfiles/$target_name"
      else
        # If dotfiles already has a folder with the same name, back it up
        echo "Backing up $target to $dotfiles/backup/$target_name.backup"
        mkdir -p "$dotfiles/backup"
        mv "$target" "$dotfiles/backup/$target_name.backup"
      fi
    fi
  fi
#
  # Create the symlink
  ln -sfn "$source" "$target"
  echo "Linked $source -> $target"
}

# Paths
DOTFILES=~/.dotfiles

# Create symlinks for configurations
create_symlink "$DOTFILES/hyprland" ~/.config/hypr "$DOTFILES"
create_symlink "$DOTFILES/kitty" ~/.config/kitty "$DOTFILES"
create_symlink "$DOTFILES/tmux/.tmux.conf" ~/.tmux.conf "$DOTFILES"
create_symlink "$DOTFILES/lvim" ~/.config/lvim "$DOTFILES"
create_symlink "$DOTFILES/i3" ~/.config/i3 "$DOTFILES"
create_symlink "$DOTFILES/picom" ~/.config/picom "$DOTFILES"

echo "All symlinks created successfully!"

