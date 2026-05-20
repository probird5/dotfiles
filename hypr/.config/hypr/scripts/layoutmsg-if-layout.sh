#!/usr/bin/env bash
set -euo pipefail

expected_layout=${1:?expected layout is required}
layout_msg=${2:?layout message is required}

if hyprctl -j activeworkspace | grep -q "\"tiledLayout\": \"${expected_layout}\""; then
    hyprctl dispatch "hl.dsp.layout(\"${layout_msg}\")"
fi
