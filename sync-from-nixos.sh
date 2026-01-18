#!/usr/bin/env bash

# Sync dotfiles from NixOS config to dotfiles repo (stow format)
# Usage: ./sync-from-nixos.sh [options] [app1 app2 ...]
# If no apps specified, syncs all configured apps

set -euo pipefail

# Default source and destination directories (can be overridden via args or env)
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

show_help() {
    cat << EOF
Usage: $0 [options] [app1 app2 ...]

Sync dotfiles from NixOS config to dotfiles repo (stow format).
If no apps specified, syncs all configured apps.

Options:
  -s, --source PATH    NixOS config directory (default: $NIXOS_CONFIG)
  -d, --dest PATH      Dotfiles directory (default: $DOTFILES_DIR)
  -h, --help           Show this help
  --status             Show sync configuration

Examples:
  $0                                      # Sync all apps with defaults
  $0 hypr nvim                            # Sync specific apps
  $0 -s ~/nixos/config -d ~/dotfiles      # Custom paths
  $0 --source /path/to/nixos --dest /path/to/dotfiles hypr waybar

Environment variables:
  NIXOS_CONFIG    Source directory (overridden by --source)
  DOTFILES_DIR    Destination directory (overridden by --dest)
EOF
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
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                show_help
                exit 0
                ;;
            --status)
                show_status
                exit 0
                ;;
            -s|--source)
                if [[ -z "${2:-}" ]]; then
                    log_error "Missing argument for $1"
                    exit 1
                fi
                NIXOS_CONFIG="$2"
                shift 2
                ;;
            -d|--dest)
                if [[ -z "${2:-}" ]]; then
                    log_error "Missing argument for $1"
                    exit 1
                fi
                DOTFILES_DIR="$2"
                shift 2
                ;;
            -*)
                log_error "Unknown option: $1"
                echo "Use --help for usage information"
                exit 1
                ;;
            *)
                apps_to_sync+=("$1")
                shift
                ;;
        esac
    done

    # Validate paths
    if [[ ! -d "$NIXOS_CONFIG" ]]; then
        log_error "Source directory does not exist: $NIXOS_CONFIG"
        exit 1
    fi

    if [[ ! -d "$DOTFILES_DIR" ]]; then
        log_error "Destination directory does not exist: $DOTFILES_DIR"
        exit 1
    fi

    # If no apps specified, sync all
    if [[ ${#apps_to_sync[@]} -eq 0 ]]; then
        apps_to_sync+=("${CONFIG_APPS[@]}")
        apps_to_sync+=("${HOME_DOTFILE_APPS[@]}")
        apps_to_sync+=("${DIRECT_COPY_APPS[@]}")
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
