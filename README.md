# Dotfiles

Personal dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/) for easy deployment across systems. Unified around the **Tokyo Night** color scheme with a focus on modern Wayland tooling.

## Table of Contents

- [Overview](#overview)
- [Screenshots](#screenshots)
- [Structure](#structure)
- [Installation](#installation)
  - [Automated Setup](#automated-setup)
  - [Using Stow](#using-stow)
  - [Manual Installation](#manual-installation)
- [Syncing from NixOS](#syncing-from-nixos)
- [Neovim](#neovim)
  - [Plugin Overview](#plugin-overview)
  - [LSP & Language Support](#lsp--language-support)
  - [Keybindings](#neovim-keybindings)
  - [Formatters & Linters](#formatters--linters)
  - [Dashboard](#dashboard)
- [Hyprland](#hyprland)
  - [Display Layout](#display-layout)
  - [Keybindings](#hyprland-keybindings)
  - [Idle & Lock](#idle--lock)
- [Zsh](#zsh)
- [Tmux](#tmux)
- [Terminals](#terminals)
- [Waybar](#waybar)
- [Rofi](#rofi)
- [Librewolf](#librewolf)
- [Starship](#starship)
- [Scripts](#scripts)

---

## Overview

| Component | Tool | Theme |
|-----------|------|-------|
| Window Manager (Wayland) | Hyprland | Tokyo Night |
| Window Manager (X11) | i3 | Default |
| Terminal (Primary) | Ghostty | Tokyo Night |
| Terminal (Fallback) | Alacritty | One Dark |
| Editor | Neovim | Tokyo Night |
| Shell | Zsh | Custom Tokyo Night prompt |
| Multiplexer | Tmux | Tokyo Night |
| Status Bar | Waybar | Custom |
| Launcher | Rofi | Tokyo Night |
| Browser | Librewolf | Hardened privacy config |
| Prompt | Starship | Nerd Font segments |
| Compositor (X11) | Picom | GLX backend |

---

## Screenshots

<!-- Add your screenshots here -->

---

## Structure

Each application has its own directory organized for GNU Stow:

```
dotfiles/
├── alacritty/       # Alacritty terminal emulator
├── backgrounds/     # Wallpaper collection (60+)
├── fonts/           # Custom fonts (Feather, IcoMoon)
├── ghostty/         # Ghostty terminal emulator
├── hypr/            # Hyprland + hyprlock + hypridle + hyprpaper
├── i3/              # i3 window manager (X11)
├── librewolf/       # Librewolf browser (user.js)
├── nvim/            # Neovim (lazy.nvim, LSP, treesitter)
├── picom/           # Picom compositor (X11)
├── rofi/            # Rofi application launcher
├── scripts/         # Utility scripts (wallpaper, suspend, etc.)
├── starship/        # Starship cross-shell prompt
├── tmux/            # Tmux terminal multiplexer
├── waybar/          # Waybar status bar
├── wezterm/         # WezTerm terminal emulator
├── wlogout/         # Wlogout logout menu
├── zsh/             # Zsh shell configuration
├── setup.sh         # Automated setup script
└── sync-from-nixos.sh  # NixOS config sync utility
```

---

## Installation

### Automated Setup

The `setup.sh` script supports **Arch**, **Gentoo**, **Fedora**, and **Debian/Kali**:

```bash
git clone https://github.com/RahulGotrekiya/dotfiles ~/Documents/Repos/dotfiles
cd ~/Documents/Repos/dotfiles

# Full install (dependencies + stow)
./setup.sh

# Only install dependencies
./setup.sh --deps-only

# Only stow configs
./setup.sh --stow-only
```

### Using Stow

Stow creates symlinks from your home directory into the dotfiles repo:

```bash
cd ~/Documents/Repos/dotfiles

# Install a single config
stow nvim

# Install multiple configs
stow hypr waybar rofi zsh tmux

# Install everything
stow */

# Remove a config
stow -D nvim
```

### Manual Installation

Copy configs directly if you don't want stow:

```bash
cp -r nvim/.config/nvim ~/.config/
cp zsh/.zshrc ~/
cp -r hypr/.config/hypr ~/.config/
```

---

## Syncing from NixOS

If you maintain configs in a NixOS repo, use the sync script:

```bash
# Sync all configs
./sync-from-nixos.sh

# Sync specific apps
./sync-from-nixos.sh hypr nvim waybar

# Custom source/destination
./sync-from-nixos.sh -s ~/nixos/config -d ~/dotfiles

# Show current sync config
./sync-from-nixos.sh --status
```

| Flag | Description |
|------|-------------|
| `-s, --source PATH` | NixOS config directory |
| `-d, --dest PATH` | Dotfiles directory |
| `-h, --help` | Show help |
| `--status` | Show sync configuration |

Environment variables `NIXOS_CONFIG` and `DOTFILES_DIR` can also be used.

---

## Neovim

Plugin manager: [lazy.nvim](https://github.com/folke/lazy.nvim) | Theme: [Tokyo Night](https://github.com/folke/tokyonight.nvim) | Leader: `Space`

### Directory Structure

```
nvim/.config/nvim/
├── init.lua                  # Entry point — bootstraps lazy.nvim
├── lazy-lock.json            # Plugin lockfile
└── lua/
    ├── vim-options.lua       # Editor settings & global keymaps
    ├── lsp/
    │   └── lsp.lua           # Enables LSP servers via vim.lsp.enable()
    └── plugins/              # One file per plugin (auto-loaded by lazy.nvim)
        ├── autopairs.lua
        ├── completions.lua
        ├── lsp-config.lua
        ├── lualine.lua
        ├── mason.lua
        ├── neo-tree.lua
        ├── neotree.lua
        ├── none-ls.lua
        ├── obsidian.lua
        ├── oil.lua
        ├── opencode.lua
        ├── snacks.lua
        ├── telescope.lua
        ├── tmux-navigator.lua
        ├── tokyonight.lua
        └── treesitter.lua
```

### Plugin Overview

| Plugin | Purpose |
|--------|---------|
| [`opencode.nvim`](https://github.com/nickjvandyke/opencode.nvim) | AI assistant integration (opencode) |
| [`snacks.nvim`](https://github.com/folke/snacks.nvim) | Dashboard, enhanced input/picker for opencode |
| `nvim-lspconfig` | LSP client configuration |
| `mason.nvim` | LSP/tool package manager |
| `mason-lspconfig.nvim` | Bridge between Mason and lspconfig |
| `mason-tool-installer.nvim` | Auto-install formatters and linters |
| `nvim-cmp` | Completion engine |
| `LuaSnip` | Snippet engine with VS Code snippet support |
| `nvim-treesitter` | Syntax highlighting and indentation |
| `telescope.nvim` | Fuzzy finder (files, grep, buffers, LSP) |
| `neo-tree.nvim` | File tree sidebar |
| `oil.nvim` | File browser (edit filesystem like a buffer) |
| `none-ls.nvim` | Formatting and diagnostics integration |
| `lualine.nvim` | Status line (iceberg_dark theme) |
| `nvim-autopairs` | Auto-close brackets and quotes |
| `vim-tmux-navigator` | Seamless tmux/nvim pane navigation |
| `obsidian.nvim` | Obsidian vault integration |
| `tokyonight.nvim` | Color scheme |

### LSP & Language Support

All LSP servers and tools are **auto-installed via Mason** on first launch. LSP servers are enabled in `lua/lsp/lsp.lua`.

| Language | LSP Server | Formatter | Linter |
|----------|-----------|-----------|--------|
| Rust | `rust_analyzer` | rustfmt (via rust-analyzer) | rust-analyzer |
| Python | `pyright` | `black` | `ruff` |
| Go | `gopls` | `gofumpt`, `goimports-reviser` | `golangci-lint` |
| C/C++ | `clangd` | `clang-format` | clangd |
| Lua | `lua_ls` | `stylua` | lua_ls |
| Bash | `bashls` | `shfmt` | bashls |
| JavaScript/TypeScript | `ts_ls` | `prettier` | ts_ls |
| HTML/CSS | `html` | `prettier` | html |
| YAML | `yamlls` | `prettier` | yamlls |
| JSON | - | `prettier` | - |
| Nix | `nixd` | - | nixd |

**Treesitter parsers** (auto-installed): `c`, `rust`, `lua`, `vim`, `vimdoc`, `python`, `go`, `gomod`, `gosum`, `bash`, `html`, `javascript`, `typescript`, `yaml`, `json`, `toml`, `markdown`, `markdown_inline`, `css`

### Neovim Keybindings

> **Leader key:** `Space`
>
> **Note:** `+` and `-` replace the default `Ctrl+a` / `Ctrl+x` for increment/decrement since those keys are used by opencode.

#### General

| Key | Mode | Action | Source |
|-----|------|--------|--------|
| `Space` | n | Leader key | vim-options |
| `Ctrl+h/j/k/l` | n | Navigate between windows/tmux panes | vim-options / tmux-navigator |
| `Leader h` | n | Previous buffer | vim-options |
| `Leader l` | n | Next buffer | vim-options |
| `+` | n | Increment number under cursor | opencode |
| `-` | n | Decrement number under cursor | opencode |

#### Opencode (AI Assistant)

| Key | Mode | Action |
|-----|------|--------|
| `Ctrl+a` | n, x | Ask opencode about selection/cursor context |
| `Ctrl+x` | n, x | Select opencode action (prompts, commands, etc.) |
| `Ctrl+.` | n, t | Toggle opencode terminal |
| `go{motion}` | n, x | Send range to opencode (supports dot-repeat) |
| `goo` | n | Send current line to opencode |
| `Shift+Ctrl+u` | n | Scroll opencode up |
| `Shift+Ctrl+d` | n | Scroll opencode down |
| `Alt+a` | n, i | Send picker selection to opencode (in snacks picker) |

#### LSP

| Key | Mode | Action |
|-----|------|--------|
| `K` | n | Hover documentation |
| `Leader gd` | n | Go to definition |
| `Leader gr` | n | Find references |
| `Leader ca` | n | Code actions |
| `Leader gf` | n | Format buffer |
| `gd` | n | LSP definitions via Telescope (with preview) |

#### Telescope

| Key | Mode | Action |
|-----|------|--------|
| `Leader ff` | n | Find files (includes hidden) |
| `Leader fg` | n | Live grep |
| `Leader fb` | n | List buffers |

#### File Navigation

| Key | Mode | Action |
|-----|------|--------|
| `Ctrl+n` | n | Toggle Neo-tree sidebar |
| `Leader bf` | n | Toggle buffer list (Neo-tree floating) |
| `Backspace` | n | Open parent directory (oil.nvim) |
| `Space -` | n | Open parent directory in floating window (oil.nvim) |
| `Alt+h` | n | Open horizontal split (inside oil buffer) |

#### Completion (nvim-cmp)

| Key | Mode | Action |
|-----|------|--------|
| `Tab` | i | Next completion item |
| `Shift+Tab` | i | Previous completion item |
| `Ctrl+Space` | i | Trigger completion |
| `Enter` | i | Confirm selection |
| `Ctrl+e` | i | Abort completion |
| `Ctrl+c` | i | Close completion menu |
| `Ctrl+b` | i | Scroll docs up |
| `Ctrl+f` | i | Scroll docs down |

#### Obsidian (markdown files only)

| Key | Mode | Action |
|-----|------|--------|
| `Leader oc` | n | Toggle checkbox |
| `Leader ot` | n | Insert template |
| `Leader oo` | n | Open in Obsidian app |
| `Leader ob` | n | Show backlinks |
| `Leader ol` | n | Show links |
| `Leader on` | n | Create new note |
| `Leader os` | n | Search notes |
| `Leader oq` | n | Quick switch between notes |

### Formatters & Linters

Format any buffer with `Leader gf`. Formatting is provided by none-ls.nvim, which bridges external tools into Neovim's LSP interface.

**Mason auto-installs these tools:** `stylua`, `clang-format`, `gofumpt`, `goimports-reviser`, `golangci-lint`, `prettier`, `black`, `ruff`, `shfmt`

### Dashboard

The startup dashboard ([snacks.nvim](https://github.com/folke/snacks.nvim)) shows:
- NEOVIM ASCII logo
- Quick-access keys: find files `f`, recent files `r`, grep `g`, restore session `s`, Lazy `l`, quit `q`
- Time-based greeting (morning/afternoon/evening/night)
- Startup time

---

## Hyprland

Wayland compositor with tiling window management, blur effects, and animations.

### Display Layout

| Monitor | Resolution | Scale | Notes |
|---------|-----------|-------|-------|
| DP-2 | 2560x1600 | 1.0x | Primary |
| DP-3 | 3840x2160 | 1.0x | Rotated 270 degrees |
| eDP-1 | 2880x1920 | 1.5x | Laptop display |

Workspaces 1-10 are distributed across monitors.

### Hyprland Keybindings

| Key | Action |
|-----|--------|
| `Super+Return` | Open Ghostty |
| `Super+Q` | Close window |
| `Super+M` | Exit Hyprland |
| `Super+E` | Open Thunar file manager |
| `Super+Space` | Rofi application launcher |
| `Super+V` | Toggle floating |
| `Super+P` | Toggle pseudo-tiling |
| `Super+J` | Toggle split |
| `Super+F` | Fullscreen |
| `Super+H/J/K/L` | Move focus (vim-style) |
| `Super+1-0` | Switch workspace |
| `Super+Shift+1-0` | Move window to workspace |
| `Super+S` | Toggle special workspace |
| `Super+Mouse` | Move/resize windows |
| `Print` | Screenshot (grim + slurp) |

### Idle & Lock

- **5 minutes**: Lock screen (hyprlock)
- **5.5 minutes**: Screens off (DPMS)
- **10 minutes**: Suspend

Lock screen uses Tokyo Night styling with PAM and fingerprint authentication.

---

## Zsh

Custom prompt (no Starship in-shell) with Tokyo Night colors:

- Git branch and status indicators (staged, unstaged, untracked, stashes, ahead/behind)
- Abbreviated directory path (truncated at 40 chars)
- SSH session indicator
- Python virtualenv indicator
- Background job counter
- Exit status (green/red indicator)
- Right-aligned time display

**Features:**
- Vi keybindings
- FZF integration for fuzzy finding
- `Ctrl+T` for tmux session switcher
- Auto-suggestions from history
- Extensive tab completion
- Aliases: `ll`, `la`, `l` for ls variants

**Environment:** `EDITOR=nvim`, Go paths configured, custom PATH entries.

---

## Tmux

| Setting | Value |
|---------|-------|
| Shell | Zsh |
| History | 100,000 lines |
| Theme | Tokyo Night |
| Mouse | Enabled |
| Mode | Vi |
| Index | Starts from 1 |

### Tmux Keybindings

| Key | Action |
|-----|--------|
| `Alt+h/j/k/l` | Navigate panes (no prefix) |
| `Alt+1-9` | Switch windows (no prefix) |
| `Shift+Left/Right` | Navigate windows |

**Plugins (TPM):** tmux-sensible, vim-tmux-navigator, tmux-yank, tmux-better-mouse-mode, tokyo-night-tmux

---

## Terminals

### Ghostty (Primary)

- Theme: Tokyo Night
- Opacity: 0.85
- Cursor: Block, non-blinking
- No window decorations
- Wayland native

### Alacritty (Fallback)

- Theme: One Dark
- Font: JetBrains Mono, 11pt
- Opacity: 0.9

### WezTerm

- Theme: AdventureTime
- Wayland support enabled

---

## Waybar

Status bar with the following modules:

| Position | Modules |
|----------|---------|
| Left | Workspaces, mode, network |
| Center | System tray |
| Right | Audio, CPU, memory, backlight, battery, clock, power |

- CPU/memory monitoring with 1-second update intervals
- WiFi SSID and signal strength display
- PulseAudio control (click to open pavucontrol)
- Battery with state-based icons and time estimates

---

## Rofi

Application launcher with Tokyo Night theme:
- 480px centered window
- 24px border radius
- Combi mode (drun + run)

---

## Librewolf

Privacy-hardened Firefox fork with custom `user.js`:

- Strict content blocking and HTTPS-only mode
- Fingerprinting and tracking protection
- Email tracking protection and query stripping
- No telemetry, no safe browsing, no captive portal detection
- Default search: DuckDuckGo (Google/Bing removed)
- Vertical tabs enabled

---

## Starship

Cross-shell prompt with Nerd Font segments:
- Directory with custom icon substitutions (Documents, Downloads, etc.)
- Git branch and status
- Language indicators: Node, Rust, Go, PHP
- Time display
- Color-blocked segments with smooth transitions

---

## Scripts

| Script | Description |
|--------|-------------|
| `scripts/wallpaper.sh` | Random wallpaper rotation using awww (wipe transition) |
| `scripts/suspend.sh` | Suspend handling |
| `scripts/dwm-status.sh` | DWM status bar updates |
| `scripts/screen.sh` | Screen/display configuration |
| `setup.sh` | Cross-distro automated setup (Arch, Gentoo, Fedora, Debian) |
| `sync-from-nixos.sh` | Sync configs from a NixOS repository |
