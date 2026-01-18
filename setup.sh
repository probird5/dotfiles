#!/usr/bin/env bash

# Dotfiles setup script for Arch, Gentoo, Fedora, and Kali
# Usage: ./setup.sh [--deps-only | --stow-only | --all]

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info()    { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[OK]${NC} $1"; }
log_warn()    { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error()   { echo -e "${RED}[ERROR]${NC} $1"; }

# Detect distribution
detect_distro() {
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        case "$ID" in
            arch|endeavouros|manjaro)
                echo "arch"
                ;;
            gentoo)
                echo "gentoo"
                ;;
            fedora)
                echo "fedora"
                ;;
            kali|debian|ubuntu)
                echo "debian"
                ;;
            *)
                echo "unknown"
                ;;
        esac
    else
        echo "unknown"
    fi
}

# Package installation by distro
install_packages() {
    local distro="$1"
    shift
    local packages=("$@")

    case "$distro" in
        arch)
            sudo pacman -S --needed --noconfirm "${packages[@]}"
            ;;
        gentoo)
            sudo emerge --ask --noreplace "${packages[@]}"
            ;;
        fedora)
            sudo dnf install -y "${packages[@]}"
            ;;
        debian)
            sudo apt update
            sudo apt install -y "${packages[@]}"
            ;;
    esac
}

# Core dependencies (stow + common tools)
install_core_deps() {
    local distro="$1"
    log_info "Installing core dependencies..."

    case "$distro" in
        arch)
            install_packages "$distro" stow git
            ;;
        gentoo)
            install_packages "$distro" app-admin/stow dev-vcs/git
            ;;
        fedora)
            install_packages "$distro" stow git
            ;;
        debian)
            install_packages "$distro" stow git
            ;;
    esac

    log_success "Core dependencies installed"
}

# Optional: Install applications that the dotfiles configure
install_apps() {
    local distro="$1"
    log_info "Installing applications..."

    # Common packages across distros (names may vary)
    local arch_pkgs=(
        neovim zsh tmux starship rofi waybar
        hyprland hyprpaper hyprlock hypridle
        alacritty wezterm wlogout fzf
    )

    local gentoo_pkgs=(
        app-editors/neovim app-shells/zsh app-misc/tmux
        app-shells/starship x11-misc/rofi gui-apps/waybar
        gui-wm/hyprland gui-apps/hyprpaper gui-apps/hyprlock
        x11-terms/alacritty app-misc/wezterm gui-apps/wlogout
        app-shells/fzf
    )

    local fedora_pkgs=(
        neovim zsh tmux starship rofi waybar
        hyprland hyprpaper hyprlock hypridle
        alacritty wezterm wlogout fzf
    )

    local debian_pkgs=(
        neovim zsh tmux rofi fzf
        # Note: hyprland/waybar may need external repos on Kali/Debian
        # alacritty may need cargo install
    )

    case "$distro" in
        arch)
            install_packages "$distro" "${arch_pkgs[@]}"
            ;;
        gentoo)
            install_packages "$distro" "${gentoo_pkgs[@]}"
            ;;
        fedora)
            install_packages "$distro" "${fedora_pkgs[@]}"
            ;;
        debian)
            log_warn "Some packages may not be available in default repos"
            log_warn "You may need to install hyprland, waybar, starship manually"
            install_packages "$distro" "${debian_pkgs[@]}"
            ;;
    esac

    log_success "Applications installed"
}

# Stow all dotfiles
stow_dotfiles() {
    log_info "Stowing dotfiles from $DOTFILES_DIR"
    cd "$DOTFILES_DIR"

    # Directories to stow (exclude non-stow dirs)
    local stow_dirs=(
        alacritty
        ghostty
        hypr
        i3
        librewolf
        nvim
        rofi
        starship
        tmux
        waybar
        wezterm
        wlogout
        zsh
    )

    for dir in "${stow_dirs[@]}"; do
        if [[ -d "$dir" ]]; then
            log_info "Stowing $dir..."
            if stow -v "$dir" 2>&1; then
                log_success "Stowed $dir"
            else
                log_warn "Failed to stow $dir (may already exist or conflict)"
            fi
        fi
    done

    log_success "Dotfiles stowed"
}

# Copy backgrounds and fonts (not stowed)
copy_extras() {
    log_info "Copying backgrounds and fonts..."

    if [[ -d "$DOTFILES_DIR/backgrounds" ]]; then
        mkdir -p ~/Pictures/backgrounds
        cp -r "$DOTFILES_DIR/backgrounds/"* ~/Pictures/backgrounds/ 2>/dev/null || true
        log_success "Backgrounds copied to ~/Pictures/backgrounds"
    fi

    if [[ -d "$DOTFILES_DIR/fonts" ]]; then
        mkdir -p ~/.local/share/fonts
        cp -r "$DOTFILES_DIR/fonts/"* ~/.local/share/fonts/ 2>/dev/null || true
        fc-cache -fv 2>/dev/null || true
        log_success "Fonts installed to ~/.local/share/fonts"
    fi
}

# Change default shell to zsh
set_zsh_shell() {
    if command -v zsh &>/dev/null; then
        if [[ "$SHELL" != *"zsh"* ]]; then
            log_info "Changing default shell to zsh..."
            chsh -s "$(which zsh)"
            log_success "Default shell changed to zsh (restart session to apply)"
        else
            log_info "Already using zsh"
        fi
    fi
}

show_help() {
    cat << EOF
Usage: $0 [option]

Options:
  --deps-only    Only install dependencies (stow + git)
  --apps         Install dependencies and applications
  --stow-only    Only stow dotfiles (assumes deps installed)
  --all          Install everything and stow dotfiles (default)
  -h, --help     Show this help

Supported distributions:
  - Arch Linux (and derivatives: EndeavourOS, Manjaro)
  - Gentoo
  - Fedora
  - Kali Linux (and Debian/Ubuntu)
EOF
}

main() {
    local mode="${1:---all}"

    case "$mode" in
        -h|--help)
            show_help
            exit 0
            ;;
    esac

    local distro
    distro=$(detect_distro)

    if [[ "$distro" == "unknown" ]]; then
        log_error "Unsupported distribution"
        log_info "Supported: Arch, Gentoo, Fedora, Kali/Debian"
        exit 1
    fi

    log_info "Detected distribution: $distro"
    echo ""

    case "$mode" in
        --deps-only)
            install_core_deps "$distro"
            ;;
        --apps)
            install_core_deps "$distro"
            install_apps "$distro"
            ;;
        --stow-only)
            stow_dotfiles
            copy_extras
            ;;
        --all)
            install_core_deps "$distro"
            install_apps "$distro"
            stow_dotfiles
            copy_extras
            set_zsh_shell
            ;;
        *)
            log_error "Unknown option: $mode"
            show_help
            exit 1
            ;;
    esac

    echo ""
    log_success "Setup complete!"
}

main "$@"
