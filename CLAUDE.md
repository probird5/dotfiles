# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a personal dotfiles repository managed with GNU Stow for symlink-based deployment. Configs are organized for Hyprland (Wayland compositor) with supporting tools.

## Commands

### Stow Operations
```bash
# Deploy a config (creates symlinks from ~/ to repo)
stow <app>              # e.g., stow nvim

# Deploy multiple configs
stow hypr waybar rofi

# Remove a config
stow -D <app>

# Deploy all configs
stow */
```

### Syncing from NixOS
If maintaining configs in a NixOS repo, use the sync script:
```bash
./sync-from-nixos.sh                    # Sync all
./sync-from-nixos.sh hypr nvim waybar   # Sync specific apps
./sync-from-nixos.sh --status           # Show configuration
```

The sync script handles three app types:
- **CONFIG_APPS**: Wrapped in `.config/<app>/` structure (hypr, nvim, waybar, etc.)
- **HOME_DOTFILE_APPS**: Home directory dotfiles (zsh, tmux)
- **DIRECT_COPY_APPS**: Direct copies without transformation (backgrounds, scripts)

## Directory Structure

Each app directory follows stow conventions - the directory structure mirrors where files should be deployed:
- `nvim/.config/nvim/` → `~/.config/nvim/`
- `zsh/.zshrc` → `~/.zshrc`

## Key Configs

### Hyprland (`hypr/.config/hypr/`)
- `hyprland.conf` - Main config with keybinds and window rules
- `hypridle.conf`, `hyprlock.conf`, `hyprpaper.conf` - Supporting daemons
- `scripts/` - Helper scripts for screenshots, wallpaper, etc.

### Neovim (`nvim/.config/nvim/`)
- Uses lazy.nvim for plugin management (bootstraps automatically)
- `init.lua` loads vim-options, LSP config, then plugins
- Plugins defined in `lua/plugins/*.lua`
- Tokyo Night theme

### Waybar (`waybar/.config/waybar/`)
- Custom modules and styling for system monitoring
- Has backup configs in `backup/` subdirectory
