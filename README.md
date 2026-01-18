# Dotfiles

Personal dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/) for easy deployment across systems.

## Structure

Each application has its own directory with configs organized for stow:

```
dotfiles/
├── alacritty/       # Alacritty terminal
├── backgrounds/     # Wallpapers
├── fonts/           # Custom fonts
├── ghostty/         # Ghostty terminal
├── hypr/            # Hyprland (+ hyprlock, hypridle, hyprpaper)
├── i3/              # i3 window manager
├── librewolf/       # Librewolf browser
├── nvim/            # Neovim
├── rofi/            # Rofi launcher
├── scripts/         # Utility scripts
├── starship/        # Starship prompt
├── tmux/            # Tmux
├── waybar/          # Waybar
├── wezterm/         # WezTerm terminal
├── wlogout/         # Wlogout
└── zsh/             # Zsh shell
```

## Installation

### Prerequisites

- [GNU Stow](https://www.gnu.org/software/stow/)
- [Neovim](https://neovim.io/) with a plugin manager (lazy.nvim)

### Using Stow

Stow creates symlinks from your home directory to the dotfiles repo.

```bash
cd ~/Documents/Repos/dotfiles

# Install a single config
stow nvim

# Install multiple configs
stow hypr waybar rofi

# Install all configs
stow */

# Remove a config
stow -D nvim
```

### Manual Installation

If you prefer not to use stow, copy configs to their respective locations:

```bash
# Example for nvim
cp -r nvim/.config/nvim ~/.config/

# Example for zsh
cp zsh/.zshrc ~/
```

## Syncing from NixOS

If you use NixOS and maintain configs in a separate NixOS repo, use the sync script:

```bash
# Sync all configs from NixOS (uses default paths)
./sync-from-nixos.sh

# Sync specific apps
./sync-from-nixos.sh hypr nvim waybar

# Specify custom source and destination paths
./sync-from-nixos.sh -s ~/nixos/config -d ~/dotfiles

# Combine custom paths with specific apps
./sync-from-nixos.sh --source /path/to/nixos --dest /path/to/dotfiles hypr waybar

# Show sync configuration
./sync-from-nixos.sh --status
```

**Options:**
| Flag | Description |
|------|-------------|
| `-s, --source PATH` | NixOS config directory |
| `-d, --dest PATH` | Dotfiles directory |
| `-h, --help` | Show help |
| `--status` | Show sync configuration |

You can also set paths via environment variables: `NIXOS_CONFIG` and `DOTFILES_DIR`.

To add new apps, edit the arrays at the top of the script.

## Key Configs

### Hyprland
- `hyprland.conf` - Main config with keybinds and window rules
- `hypridle.conf` - Idle daemon settings
- `hyprlock.conf` - Lock screen config
- `hyprpaper.conf` - Wallpaper settings

### Neovim
- Uses lazy.nvim for plugin management
- LSP, completions, and treesitter configured
- Tokyo Night theme

### Zsh
- Starship prompt
- Custom aliases and functions

### Waybar
- Custom modules and styling
- System monitoring widgets
