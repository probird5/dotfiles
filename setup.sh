#!/usr/bin/env bash

# Dotfiles setup script for Arch, Gentoo, Fedora, and Kali
# Usage: ./setup.sh [--deps-only | --stow-only | --portage-only | --all]
# X11 focused (DWM, i3)

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

# ============================================================================
# GENTOO OVERLAYS (Pentoo + GURU)
# ============================================================================

setup_gentoo_overlays() {
    log_info "Setting up Gentoo overlays..."

    # Install eselect-repository if not present
    if ! command -v eselect &>/dev/null || ! eselect repository list &>/dev/null; then
        log_info "Installing eselect-repository..."
        sudo emerge --ask --noreplace app-eselect/eselect-repository dev-vcs/git
    fi

    # Enable Pentoo overlay (security/pentesting tools)
    if ! eselect repository list -i | grep -q "pentoo"; then
        log_info "Enabling Pentoo overlay..."
        sudo eselect repository enable pentoo
        log_success "Pentoo overlay enabled"
    else
        log_info "Pentoo overlay already enabled"
    fi

    # Enable GURU overlay (community packages)
    if ! eselect repository list -i | grep -q "guru"; then
        log_info "Enabling GURU overlay..."
        sudo eselect repository enable guru
        log_success "GURU overlay enabled"
    else
        log_info "GURU overlay already enabled"
    fi

    # Sync overlays
    log_info "Syncing overlays (this may take a while)..."
    sudo emerge --sync

    log_success "Overlays configured and synced"
}

# ============================================================================
# GENTOO PORTAGE CONFIGURATION
# ============================================================================

setup_gentoo_portage() {
    log_info "Setting up Gentoo Portage configuration..."

    # Create portage directories
    sudo mkdir -p /etc/portage/package.use
    sudo mkdir -p /etc/portage/package.accept_keywords
    sudo mkdir -p /etc/portage/package.mask
    sudo mkdir -p /etc/portage/repos.conf

    # --- make.conf additions ---
    log_info "Checking make.conf..."
    local makeconf="/etc/portage/make.conf"

    # Add global USE flags for X11 setup if not present
    if ! grep -q "^USE=" "$makeconf" 2>/dev/null; then
        log_info "Adding global USE flags to make.conf..."
        echo '' | sudo tee -a "$makeconf" > /dev/null
        echo '# Global USE flags for X11 desktop' | sudo tee -a "$makeconf" > /dev/null
        echo 'USE="X dbus elogind pulseaudio pipewire networkmanager -wayland -systemd"' | sudo tee -a "$makeconf" > /dev/null
    else
        # Ensure X is in USE flags
        if ! grep "^USE=" "$makeconf" | grep -q "\bX\b"; then
            log_warn "USE variable exists but may not include X flag"
            log_info "Consider adding 'X dbus elogind pulseaudio pipewire' to your USE flags"
        fi
    fi

    # Add VIDEO_CARDS if not present
    if ! grep -q "VIDEO_CARDS" "$makeconf" 2>/dev/null; then
        log_info "Adding VIDEO_CARDS to make.conf..."
        echo '' | sudo tee -a "$makeconf" > /dev/null
        echo '# Graphics drivers (adjust for your hardware: nvidia, amdgpu, intel, etc.)' | sudo tee -a "$makeconf" > /dev/null
        echo 'VIDEO_CARDS="nvidia"' | sudo tee -a "$makeconf" > /dev/null
    fi

    # Add INPUT_DEVICES if not present
    if ! grep -q "INPUT_DEVICES" "$makeconf" 2>/dev/null; then
        echo 'INPUT_DEVICES="libinput"' | sudo tee -a "$makeconf" > /dev/null
    fi

    # Add ACCEPT_LICENSE if not present
    if ! grep -q "ACCEPT_LICENSE" "$makeconf" 2>/dev/null; then
        echo 'ACCEPT_LICENSE="*"' | sudo tee -a "$makeconf" > /dev/null
    fi

    # Add ACCEPT_KEYWORDS for ~amd64 (testing) packages
    if ! grep -q "ACCEPT_KEYWORDS" "$makeconf" 2>/dev/null; then
        log_info "Enabling ~amd64 (testing) packages..."
        echo 'ACCEPT_KEYWORDS="~amd64"' | sudo tee -a "$makeconf" > /dev/null
    fi

    # --- package.use ---
    log_info "Setting up package.use..."

    # X11 desktop package.use - force X flag globally for X11 setup
    sudo tee /etc/portage/package.use/00-global-x11 > /dev/null << 'EOF'
# Force X11 for all packages, disable Wayland
*/* X -wayland
EOF

    # Package-specific USE flags
    sudo tee /etc/portage/package.use/desktop > /dev/null << 'EOF'
# XFCE/Thunar and GTK dependencies
xfce-base/libxfce4ui gtk3
xfce-base/exo gtk3
xfce-base/thunar trash-panel-plugin
dev-libs/libdbusmenu gtk3

# Font rendering
media-libs/freetype harfbuzz

# Neovim with LuaJIT
app-editors/neovim lua_single_target_luajit

# Flameshot screenshot tool
media-gfx/flameshot dbus

# Dunst notifications
x11-misc/dunst dunstify
EOF

    # PipeWire audio
    sudo tee /etc/portage/package.use/pipewire > /dev/null << 'EOF'
# PipeWire audio stack
media-video/pipewire sound-server
media-sound/pulseaudio -daemon
EOF

    # NetworkManager
    sudo tee /etc/portage/package.use/networkmanager > /dev/null << 'EOF'
# NetworkManager WiFi support
net-wireless/wpa_supplicant dbus
net-misc/networkmanager wifi
EOF

    log_success "Portage configuration complete"
}

# ============================================================================
# GENTOO PACKAGES (X11 FOCUSED)
# ============================================================================

# Core system
GENTOO_CORE=(
    "app-admin/stow"
    "dev-vcs/git"
    "sys-apps/dbus"
    "app-misc/tmux"
    "app-shells/zsh"
    "app-shells/fzf"
)

# DWM build dependencies
GENTOO_DWM_BUILD=(
    "x11-libs/libX11"
    "x11-libs/libXinerama"
    "x11-libs/libXft"
    "x11-libs/libxcb"
    "x11-libs/xcb-util"
    "media-libs/freetype"
    "media-libs/fontconfig"
    "x11-base/xorg-proto"
    "sys-devel/gcc"
    "dev-build/make"
    "dev-util/pkgconf"
)

# X11 environment
GENTOO_X11=(
    "x11-base/xorg-server"
    "x11-apps/xinit"
    "x11-apps/xrandr"
    "x11-apps/xrdb"
    "x11-apps/xmodmap"
    "x11-apps/xset"
    "x11-misc/picom"
    "media-gfx/feh"
    "x11-misc/dunst"
    "x11-misc/xclip"
    "x11-misc/xsel"
    "x11-misc/rofi"
    "x11-apps/xprop"
    "media-gfx/flameshot"
    "x11-misc/xss-lock"
    "x11-misc/i3lock"
)

# i3 window manager
GENTOO_I3=(
    "x11-wm/i3"
    "x11-misc/i3status"
)

# Terminals
GENTOO_TERMINALS=(
    "x11-terms/alacritty"
    "x11-terms/ghostty"
)

# Editors and tools
GENTOO_EDITORS=(
    "app-editors/neovim"
    "app-shells/starship"
)

# File managers
GENTOO_FILEMANAGERS=(
    "xfce-base/thunar"
    "app-misc/yazi"
)

# Audio
GENTOO_AUDIO=(
    "media-video/pipewire"
    "media-sound/pamixer"
    "media-sound/playerctl"
)

# System utilities
GENTOO_UTILS=(
    "app-misc/brightnessctl"
    "x11-misc/pywal16"
    "net-misc/networkmanager"
    "gnome-extra/nm-applet"
    "x11-misc/dex"
)

# Fonts
GENTOO_FONTS=(
    "media-fonts/nerdfonts"
    "media-fonts/noto-emoji"
    "media-fonts/jetbrains-mono"
)

install_gentoo_apps() {
    log_info "Installing Gentoo packages (X11 focused)..."

    # Combine all package arrays
    local all_pkgs=(
        "${GENTOO_CORE[@]}"
        "${GENTOO_DWM_BUILD[@]}"
        "${GENTOO_X11[@]}"
        "${GENTOO_I3[@]}"
        "${GENTOO_TERMINALS[@]}"
        "${GENTOO_EDITORS[@]}"
        "${GENTOO_FILEMANAGERS[@]}"
        "${GENTOO_AUDIO[@]}"
        "${GENTOO_UTILS[@]}"
        "${GENTOO_FONTS[@]}"
    )

    log_info "The following packages will be installed:"
    printf '%s\n' "${all_pkgs[@]}" | sort | uniq | head -20
    echo "... and more (${#all_pkgs[@]} total packages)"
    echo ""

    # Install packages
    sudo emerge --ask --noreplace "${all_pkgs[@]}"

    log_success "Gentoo packages installed"
}

# ============================================================================
# OTHER DISTRO PACKAGES
# ============================================================================

install_apps() {
    local distro="$1"
    log_info "Installing applications..."

    # Arch packages (X11 focused)
    local arch_pkgs=(
        # Core
        neovim zsh tmux starship fzf stow git
        # X11/DWM
        xorg-server xorg-xinit xorg-xrandr xorg-xrdb xorg-xmodmap xorg-xset
        picom feh dunst xclip xsel rofi flameshot xss-lock i3lock
        # i3
        i3-wm i3status
        # Terminals
        alacritty ghostty
        # File managers
        thunar yazi
        # Audio
        pipewire pipewire-pulse pamixer playerctl
        # Utils
        brightnessctl python-pywal networkmanager network-manager-applet dex
        # Fonts
        ttf-jetbrains-mono-nerd ttf-nerd-fonts-symbols noto-fonts-emoji
    )

    local fedora_pkgs=(
        neovim zsh tmux starship rofi fzf
        alacritty
        picom feh dunst thunar
        pipewire pamixer playerctl brightnessctl
        i3 i3status
    )

    local debian_pkgs=(
        neovim zsh tmux rofi fzf
        picom feh dunst thunar
        pipewire
        i3 i3status
    )

    case "$distro" in
        arch)
            install_packages "$distro" "${arch_pkgs[@]}"
            ;;
        gentoo)
            setup_gentoo_portage
            setup_gentoo_overlays
            install_gentoo_apps
            ;;
        fedora)
            install_packages "$distro" "${fedora_pkgs[@]}"
            ;;
        debian)
            log_warn "Some packages may not be available in default repos"
            install_packages "$distro" "${debian_pkgs[@]}"
            ;;
    esac

    log_success "Applications installed"
}

# Remove existing config that would conflict with stow
remove_existing_config() {
    local dir="$1"

    case "$dir" in
        alacritty|ghostty|i3|nvim|picom|rofi|starship)
            rm -rf "$HOME/.config/$dir"
            ;;
        librewolf)
            rm -rf "$HOME/.librewolf"
            ;;
        tmux)
            rm -f "$HOME/.tmux.conf"
            ;;
        zsh)
            rm -f "$HOME/.zshrc"
            ;;
    esac
}

# Stow all dotfiles
stow_dotfiles() {
    log_info "Stowing dotfiles from $DOTFILES_DIR"
    cd "$DOTFILES_DIR"

    # Directories to stow (X11 focused)
    local stow_dirs=(
        alacritty
        ghostty
        i3
        librewolf
        nvim
        picom
        rofi
        starship
        tmux
        zsh
    )

    for dir in "${stow_dirs[@]}"; do
        if [[ -d "$dir" ]]; then
            log_info "Stowing $dir..."
            remove_existing_config "$dir"
            if stow -v -t "$HOME" "$dir" 2>&1; then
                log_success "Stowed $dir"
            else
                log_warn "Failed to stow $dir"
            fi
        fi
    done

    # Stow root-level dotfiles
    for file in .xinitrc .Xresources .Xmodmap; do
        if [[ -f "$DOTFILES_DIR/$file" ]]; then
            log_info "Linking $file..."
            rm -f "$HOME/$file"
            ln -sf "$DOTFILES_DIR/$file" "$HOME/$file"
            log_success "Linked $file"
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

# Build DWM
build_dwm() {
    local dwm_dir="$HOME/Documents/Repos/dwm-config"

    if [[ -d "$dwm_dir" ]]; then
        log_info "Building DWM..."
        cd "$dwm_dir"
        make clean
        make
        log_success "DWM built at $dwm_dir/dwm"
    else
        log_warn "DWM config not found at $dwm_dir"
    fi
}

# Install TPM (Tmux Plugin Manager) and plugins
setup_tmux() {
    local tpm_dir="$HOME/.tmux/plugins/tpm"

    log_info "Setting up Tmux Plugin Manager..."

    # Install TPM if not present
    if [[ ! -d "$tpm_dir" ]]; then
        log_info "Cloning TPM..."
        git clone https://github.com/tmux-plugins/tpm "$tpm_dir"
        log_success "TPM installed"
    else
        log_info "TPM already installed, updating..."
        cd "$tpm_dir" && git pull
        log_success "TPM updated"
    fi

    # Install plugins if tmux is available
    if command -v tmux &>/dev/null; then
        log_info "Installing tmux plugins..."
        # Run TPM install script (works without tmux server running)
        "$tpm_dir/bin/install_plugins" || true
        log_success "Tmux plugins installed"
    else
        log_warn "Tmux not found, skipping plugin installation"
        log_info "Run 'prefix + I' inside tmux to install plugins later"
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
  --deps-only      Only install dependencies (stow + git)
  --apps           Install dependencies and applications
  --overlays-only  Only setup Gentoo overlays - Pentoo + GURU (Gentoo only)
  --portage-only   Only setup Gentoo portage config (Gentoo only)
  --stow-only      Only stow dotfiles (assumes deps installed)
  --build-dwm      Build DWM from source
  --tmux           Install TPM and tmux plugins
  --all            Install everything and stow dotfiles (default)
  -h, --help       Show this help

Supported distributions:
  - Arch Linux (and derivatives: EndeavourOS, Manjaro)
  - Gentoo
  - Fedora
  - Kali Linux (and Debian/Ubuntu)

X11 focused setup:
  - Window Managers: DWM (default), i3
  - Compositor: picom
  - Launcher: rofi
  - Screenshots: flameshot
  - Notifications: dunst

Tmux setup:
  - Installs TPM (Tmux Plugin Manager)
  - Plugins: vim-tmux-navigator, tokyo-night-tmux, better-mouse-mode, tmux-yank
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
        --overlays-only)
            if [[ "$distro" == "gentoo" ]]; then
                setup_gentoo_overlays
            else
                log_error "--overlays-only is only for Gentoo"
                exit 1
            fi
            ;;
        --portage-only)
            if [[ "$distro" == "gentoo" ]]; then
                setup_gentoo_portage
            else
                log_error "--portage-only is only for Gentoo"
                exit 1
            fi
            ;;
        --stow-only)
            stow_dotfiles
            copy_extras
            ;;
        --build-dwm)
            build_dwm
            ;;
        --tmux)
            setup_tmux
            ;;
        --all)
            install_core_deps "$distro"
            install_apps "$distro"
            stow_dotfiles
            copy_extras
            setup_tmux
            [[ "$distro" == "gentoo" || "$distro" == "arch" ]] && build_dwm
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

    if [[ "$distro" == "gentoo" ]]; then
        echo ""
        log_info "Gentoo post-install notes:"
        echo "  1. Run 'startx' to launch X11 with DWM (default)"
        echo "  2. Or 'startx ~/.xinitrc i3' for i3"
        echo "  3. PipeWire: auto-started via .xinitrc"
        echo "  4. Overlays enabled: Pentoo (security tools), GURU (community packages)"
        echo "  5. For LibreWolf: install via flatpak or GURU overlay"
        echo "  6. Tmux: press 'prefix + I' to install/update plugins if needed"
    fi
}

main "$@"
