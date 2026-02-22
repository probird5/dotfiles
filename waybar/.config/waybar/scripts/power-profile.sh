#!/bin/sh
# ============================================================================
#  GUNDAM HUD -- Reactor Output Mode (Power Profile)
#  Cycles: CRUISE (power-saver) -> NORMAL (balanced) -> BOOST (performance)
#
#  Refresh rate logic:
#    - On AC power       : respect profile (BOOST=120Hz, others=60Hz)
#    - Battery >30%      : respect profile (BOOST=120Hz, others=60Hz)
#    - Battery <=30%     : force 60Hz + auto-downgrade to CRUISE
#
#  Edit MONITOR, RES, SCALE below to match your setup.
# ============================================================================

MONITOR="eDP-1"
RES="2880x1920"
SCALE="1.5"
BAT="/sys/class/power_supply/BAT1"
LOW_THRESHOLD=30

set_refresh() {
    hyprctl keyword monitor "${MONITOR},${RES}@${1},0x0,${SCALE}" >/dev/null 2>&1
}

get_battery() {
    capacity=$(cat "$BAT/capacity" 2>/dev/null || echo 100)
    status=$(cat "$BAT/status" 2>/dev/null || echo "Unknown")
}

# Determine effective refresh rate based on profile + battery
apply_refresh() {
    profile="$1"
    get_battery

    # On AC (Charging/Full/Not discharging) -- respect profile choice
    case "$status" in
        Charging|Full|"Not charging")
            if [ "$profile" = "performance" ]; then
                set_refresh 120
            else
                set_refresh 60
            fi
            return
            ;;
    esac

    # On battery -- check charge level
    if [ "$capacity" -le "$LOW_THRESHOLD" ]; then
        # Low E-CAP: force 60Hz, auto-downgrade to CRUISE if not already
        set_refresh 60
        if [ "$profile" != "power-saver" ]; then
            powerprofilesctl set power-saver
        fi
    else
        # Healthy charge: respect profile
        if [ "$profile" = "performance" ]; then
            set_refresh 120
        else
            set_refresh 60
        fi
    fi
}

case "$1" in
    cycle)
        current=$(powerprofilesctl get)
        case "$current" in
            power-saver)  powerprofilesctl set balanced ;;
            balanced)     powerprofilesctl set performance ;;
            performance)  powerprofilesctl set power-saver ;;
        esac
        # Apply refresh for the new profile
        new=$(powerprofilesctl get)
        apply_refresh "$new"
        ;;
    *)
        # Output JSON for waybar + enforce refresh on each poll
        current=$(powerprofilesctl get)
        get_battery
        apply_refresh "$current"

        # Re-read in case apply_refresh downgraded us
        current=$(powerprofilesctl get)

        # Build status suffix for tooltip
        if [ "$status" = "Charging" ] || [ "$status" = "Full" ] || [ "$status" = "Not charging" ]; then
            bat_info="AC power (${capacity}%)"
        elif [ "$capacity" -le "$LOW_THRESHOLD" ]; then
            bat_info="LOW E-CAP (${capacity}%) -- forced 60Hz"
        else
            bat_info="Battery ${capacity}%"
        fi

        case "$current" in
            power-saver)
                hz="60Hz"
                echo "{\"text\": \"CRUISE\", \"alt\": \"power-saver\", \"class\": \"power-saver\", \"tooltip\": \"Reactor: CRUISE MODE\\nMinimum output -- conserving E-CAP\\nDisplay: ${hz}\\n${bat_info}\"}"
                ;;
            balanced)
                hz="60Hz"
                echo "{\"text\": \"NORMAL\", \"alt\": \"balanced\", \"class\": \"balanced\", \"tooltip\": \"Reactor: NORMAL OUTPUT\\nStandard combat readiness\\nDisplay: ${hz}\\n${bat_info}\"}"
                ;;
            performance)
                if [ "$status" != "Charging" ] && [ "$status" != "Full" ] && [ "$status" != "Not charging" ] && [ "$capacity" -le "$LOW_THRESHOLD" ]; then
                    hz="60Hz"
                else
                    hz="120Hz"
                fi
                echo "{\"text\": \"BOOST\", \"alt\": \"performance\", \"class\": \"performance\", \"tooltip\": \"Reactor: MAXIMUM OUTPUT\\nFull reactor burn -- high drain\\nDisplay: ${hz}\\n${bat_info}\"}"
                ;;
        esac
        ;;
esac
