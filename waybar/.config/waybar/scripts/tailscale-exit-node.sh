#!/bin/sh
# ============================================================================
#  GUNDAM HUD -- Tailscale Exit Node Relay
#  Displays current exit node status and provides a rofi menu to select
#  or disconnect exit nodes.
#
#  Usage:
#    (no args)   -- Output JSON for waybar polling
#    --menu      -- Open rofi picker to select/disconnect exit node
#
#  Dependencies: tailscale, rofi, jq, notify-send (swaync)
# ============================================================================

SIGNAL=9
APP_NAME="tailscale-relay"
ROFI_THEME="$HOME/.config/rofi/tailscale.rasi"

# ── Notifications ────────────────────────────────────────────────────

notify() {
    urgency="$1"
    summary="$2"
    body="$3"
    notify-send \
        -a "$APP_NAME" \
        -u "$urgency" \
        -c "network" \
        -h "string:x-canonical-private-synchronous:$APP_NAME" \
        "$summary" "$body"
}

# ── Helpers ──────────────────────────────────────────────────────────

# Cache status JSON to avoid repeated calls within the same invocation
_status_json=""
get_status_json() {
    if [ -z "$_status_json" ]; then
        _status_json=$(tailscale status --json 2>/dev/null) || return 1
    fi
    echo "$_status_json"
}

# Invalidate cache (call after changing exit node)
invalidate_status() {
    _status_json=""
}

# Get current exit node DNS short name (empty if none)
get_current_exit_node() {
    json=$(get_status_json) || return 1
    echo "$json" | jq -r '
        [.Peer[] | select(.ExitNode == true)] | first //empty |
        if . then (.DNSName | split(".")[0]) else empty end
    ' 2>/dev/null
}

# Get exit node data as "name\tIP" pairs
get_exit_node_data() {
    json=$(get_status_json) || return 1
    echo "$json" | jq -r '
        .Peer[] | select(.ExitNodeOption == true) |
        (.DNSName | split(".")[0]) + "\t" + .TailscaleIPs[0]
    ' 2>/dev/null | sort
}

# Resolve a DNS short name to its tailscale IP
resolve_exit_node_ip() {
    target="$1"
    json=$(get_status_json) || return 1
    echo "$json" | jq -r --arg name "$target" '
        .Peer[] | select(.ExitNodeOption == true) |
        select((.DNSName | split(".")[0]) == $name) |
        .TailscaleIPs[0]
    ' 2>/dev/null
}

# Check if a specific exit node is active
check_exit_node_active() {
    target="$1"
    invalidate_status
    current=$(get_current_exit_node)
    [ "$current" = "$target" ]
}

# Verify connection with retries
verify_connection() {
    target="$1"
    retries=5
    while [ "$retries" -gt 0 ]; do
        sleep 1
        invalidate_status
        if check_exit_node_active "$target"; then
            return 0
        fi
        retries=$((retries - 1))
    done
    return 1
}

# Verify disconnection with retries
verify_disconnection() {
    retries=3
    while [ "$retries" -gt 0 ]; do
        sleep 1
        invalidate_status
        current=$(get_current_exit_node)
        if [ -z "$current" ]; then
            return 0
        fi
        retries=$((retries - 1))
    done
    return 1
}

# ── Menu mode ────────────────────────────────────────────────────────

run_menu() {
    current=$(get_current_exit_node)
    node_data=$(get_exit_node_data)

    if [ -z "$node_data" ]; then
        notify "normal" "RLY // EXIT NODE" "No exit nodes available on tailnet"
        exit 0
    fi

    # Build menu entries (display names only)
    menu=""
    echo "$node_data" | while IFS="$(printf '\t')" read -r name ip; do
        if [ "$name" = "$current" ]; then
            printf '>> %s [ACTIVE]\n' "$name"
        else
            printf '   %s\n' "$name"
        fi
    done > /tmp/.tailscale-menu-$$

    if [ -n "$current" ]; then
        echo "   DISCONNECT" >> /tmp/.tailscale-menu-$$
    fi

    # Launch rofi with theme
    if [ -f "$ROFI_THEME" ]; then
        chosen=$(rofi -dmenu -p "EXIT NODE" -theme "$ROFI_THEME" < /tmp/.tailscale-menu-$$)
    else
        chosen=$(rofi -dmenu -p "EXIT NODE" < /tmp/.tailscale-menu-$$)
    fi

    rm -f /tmp/.tailscale-menu-$$

    [ -z "$chosen" ] && exit 0

    # Clean the selection
    chosen=$(echo "$chosen" | sed 's/^>> //; s/^   //; s/ \[ACTIVE\]$//')

    if [ "$chosen" = "DISCONNECT" ]; then
        notify "low" "RLY // EXIT NODE" "Disengaging relay from $current..."

        err=$(tailscale set --exit-node= 2>&1)
        if [ $? -eq 0 ] && verify_disconnection; then
            notify "normal" "RLY // EXIT NODE" "Relay disengaged\nDirect connection restored"
        else
            notify "critical" "RLY // EXIT NODE" "Failed to disconnect\n${err:-Unknown error}"
        fi

    elif [ "$chosen" = "$current" ]; then
        notify "low" "RLY // EXIT NODE" "Already relaying through $chosen"
        exit 0

    else
        # Resolve name to IP for the tailscale set command
        target_ip=$(resolve_exit_node_ip "$chosen")
        if [ -z "$target_ip" ]; then
            notify "critical" "RLY // EXIT NODE" "Cannot resolve IP for $chosen"
            exit 1
        fi

        notify "low" "RLY // EXIT NODE" "Locking relay to $chosen..."

        err=$(tailscale set --exit-node="$target_ip" 2>&1)
        if [ $? -eq 0 ] && verify_connection "$chosen"; then
            notify "normal" "RLY // EXIT NODE" "Relay locked\nRouting through $chosen"
        else
            notify "critical" "RLY // EXIT NODE" "Connection failed\n${err:-Node unreachable}"
        fi
    fi

    # Signal waybar to refresh immediately
    pkill -RTMIN+${SIGNAL} waybar 2>/dev/null
}

# ── Polling mode ─────────────────────────────────────────────────────

run_poll() {
    if ! tailscale status --json >/dev/null 2>&1; then
        printf '{"text": "ERR", "alt": "error", "class": "error", "tooltip": "Relay: ERROR\\nTailscale daemon unreachable"}\n'
        return
    fi

    current=$(get_current_exit_node)

    if [ -n "$current" ]; then
        printf '{"text": "%s", "alt": "connected", "class": "connected", "tooltip": "Relay: ACTIVE\\nExit node: %s\\nTraffic routed through remote node"}\n' \
            "$current" "$current"
    else
        printf '{"text": "OFF", "alt": "disconnected", "class": "disconnected", "tooltip": "Relay: INACTIVE\\nDirect connection -- no exit node"}\n'
    fi
}

# ── Main ─────────────────────────────────────────────────────────────

case "$1" in
    --menu) run_menu ;;
    *)      run_poll ;;
esac
