#!/usr/bin/env bash

# Define a function for creating symlinks
create_symlink() {
  local source=$1
  local target=$2

  # Backup existing file or directory if it exists
  if [ -e "$target" ] || [ -L "$target" ]; then
    echo "Backing up existing $target to ${target}.backup"
    mv "$target" "${target}.backup"
  fi

  # Create the symlink
  ln -sfn "$source" "$target"
  echo "Linked $source -> $target"
}

# Paths
DOTFILES=~/.dotfiles

# Create symlinks for configurations
create_symlink "$DOTFILES/hyprland" ~/.config/hypr
create_symlink "$DOTFILES/kitty" ~/.config/kitty
create_symlink "$DOTFILES/tmux/.tmux.conf" ~/.tmux.conf
create_symlink "$DOTFILES/lvim" ~/.config/lvim

echo "All symlinks created successfully!"

