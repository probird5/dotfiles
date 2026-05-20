#!/bin/sh

id="$1"
label="$2"
bar_output="$WAYBAR_OUTPUT_NAME"

active_id=$(hyprctl --instance 0 activeworkspace -j 2>/dev/null | jq -r '.id // empty')
workspace=$(hyprctl --instance 0 workspaces -j 2>/dev/null | jq -r --argjson id "$id" 'map(select(.id == $id)) | first | select(. != null) | [.windows, .monitor] | @tsv')
visible=$(hyprctl --instance 0 monitors -j 2>/dev/null | jq -r --argjson id "$id" '[.[] | select(.activeWorkspace.id == $id)] | length')

windows=0
monitor=""
class="empty"

if [ -n "$workspace" ]; then
    windows=$(printf '%s\n' "$workspace" | cut -f1)
    monitor=$(printf '%s\n' "$workspace" | cut -f2)
    class="occupied"

    if [ -n "$bar_output" ] && [ "$monitor" != "$bar_output" ]; then
        class="empty"
    fi
fi

if [ "$class" != "empty" ] && [ "$visible" != "0" ] && [ -n "$visible" ]; then
    class="visible"
fi

if [ "$class" != "empty" ] && [ "$active_id" = "$id" ]; then
    class="active"
fi

printf '{"text":"%s","class":"%s","tooltip":"Workspace %s%s%s"}\n' \
    "$label" \
    "$class" \
    "$id" \
    "${monitor:+ on $monitor}" \
    "${windows:+ | $windows windows}"
