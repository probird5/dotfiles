#!/usr/bin/env bash

# Sync dotfiles from NixOS config to dotfiles repo (stow format)
# Usage: ./sync-from-nixos.sh [app1 app2 ...]
# If no apps specified, syncs all configured apps

set -euo pipefail

# Source and destination directories
NIXOS_CONFIG="${NIXOS_CONFIG:-/home/probird5/nixos-pb/config}"
DOTFILES_DIR="${DOTFILES_DIR:-/home/probird5/Documents/Repos/dotfiles}"

# Apps that use .config/<app>/ structure
CONFIG_APPS=(
    alacritty
    btop
    ghostty
    hypr
    nvim
    rofi
    starship
    waybar
    niri
)

# Apps with home directory dotfiles (files starting with .)
HOME_DOTFILE_APPS=(
    zsh
    tmux
)

# Apps that are direct copies (no .config wrapper)
DIRECT_COPY_APPS=(
    backgrounds
    scripts
)

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[OK]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if app is in array
in_array() {
    local needle="$1"
    shift
    local item
    for item in "$@"; do
        [[ "$item" == "$needle" ]] && return 0
    done
    return 1
}

# Sync a .config style app
sync_config_app() {
    local app="$1"
    local src="$NIXOS_CONFIG/$app"
    local dest="$DOTFILES_DIR/$app/.config/$app"

    if [[ ! -d "$src" ]]; then
        log_warn "Source not found: $src"
        return 1
    fi

    log_info "Syncing $app -> .config/$app format"

    # Create destination directory
    mkdir -p "$dest"

    # Sync files, excluding any existing .config structure in source
    # (some apps like alacritty already have .config in nixos)
    if [[ -d "$src/.config/$app" ]]; then
        # Source already has .config structure, copy from there
        rsync -av --delete "$src/.config/$app/" "$dest/"
    else
        # Wrap in .config structure
        rsync -av --delete "$src/" "$dest/"
    fi

    log_success "Synced $app"
}

# Sync home dotfile app (files that go directly in ~/)
sync_home_dotfile_app() {
    local app="$1"
    local src="$NIXOS_CONFIG/$app"
    local dest="$DOTFILES_DIR/$app"

    if [[ ! -d "$src" ]]; then
        log_warn "Source not found: $src"
        return 1
    fi

    log_info "Syncing $app -> home dotfile format"

    mkdir -p "$dest"

    # Copy only dotfiles (files starting with .)
    for file in "$src"/.*; do
        [[ -f "$file" ]] || continue
        local filename
        filename=$(basename "$file")
        [[ "$filename" == "." || "$filename" == ".." ]] && continue
        cp -v "$file" "$dest/"
    done

    log_success "Synced $app"
}

# Sync direct copy app (no transformation)
sync_direct_copy_app() {
    local app="$1"
    local src="$NIXOS_CONFIG/$app"
    local dest="$DOTFILES_DIR/$app"

    if [[ ! -d "$src" ]]; then
        log_warn "Source not found: $src"
        return 1
    fi

    log_info "Syncing $app -> direct copy"

    mkdir -p "$dest"
    rsync -av --delete "$src/" "$dest/"

    log_success "Synced $app"
}

# Main sync function for a single app
sync_app() {
    local app="$1"

    if in_array "$app" "${CONFIG_APPS[@]}"; then
        sync_config_app "$app"
    elif in_array "$app" "${HOME_DOTFILE_APPS[@]}"; then
        sync_home_dotfile_app "$app"
    elif in_array "$app" "${DIRECT_COPY_APPS[@]}"; then
        sync_direct_copy_app "$app"
    else
        log_error "Unknown app: $app"
        log_info "Add it to one of the arrays in this script:"
        log_info "  CONFIG_APPS      - for .config/<app>/ style"
        log_info "  HOME_DOTFILE_APPS - for ~/.<file> style"
        log_info "  DIRECT_COPY_APPS  - for direct copy"
        return 1
    fi
}

# Show what would be synced
show_status() {
    echo "=== Sync Configuration ==="
    echo "Source: $NIXOS_CONFIG"
    echo "Destination: $DOTFILES_DIR"
    echo ""
    echo "Apps configured for .config/<app>/ format:"
    printf "  %s\n" "${CONFIG_APPS[@]}"
    echo ""
    echo "Apps configured for home dotfile format:"
    printf "  %s\n" "${HOME_DOTFILE_APPS[@]}"
    echo ""
    echo "Apps configured for direct copy:"
    printf "  %s\n" "${DIRECT_COPY_APPS[@]}"
}

# Main
main() {
    local apps_to_sync=()

    # Parse arguments
    if [[ $# -eq 0 ]]; then
        # Sync all apps
        apps_to_sync+=("${CONFIG_APPS[@]}")
        apps_to_sync+=("${HOME_DOTFILE_APPS[@]}")
        apps_to_sync+=("${DIRECT_COPY_APPS[@]}")
    elif [[ "$1" == "--help" || "$1" == "-h" ]]; then
        echo "Usage: $0 [options] [app1 app2 ...]"
        echo ""
        echo "Options:"
        echo "  -h, --help     Show this help"
        echo "  -s, --status   Show sync configuration"
        echo "  -n, --dry-run  Show what would be synced (rsync dry-run)"
        echo ""
        echo "If no apps specified, syncs all configured apps."
        echo ""
        show_status
        exit 0
    elif [[ "$1" == "--status" || "$1" == "-s" ]]; then
        show_status
        exit 0
    else
        apps_to_sync=("$@")
    fi

    echo "=== Syncing dotfiles from NixOS config ==="
    echo "From: $NIXOS_CONFIG"
    echo "To:   $DOTFILES_DIR"
    echo ""

    local failed=0
    for app in "${apps_to_sync[@]}"; do
        if ! sync_app "$app"; then
            ((failed++)) || true
        fi
        echo ""
    done

    if [[ $failed -eq 0 ]]; then
        log_success "All apps synced successfully!"
    else
        log_warn "$failed app(s) had issues"
    fi
}

main "$@"
