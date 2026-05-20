-- Hyprland 0.55+ Lua config converted from hyprland.conf.
-- Ref: https://wiki.hypr.land/Configuring/Start/

-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")
hl.env("GDK_BACKEND", "wayland,x11")
hl.env("BROWSER", "firefox")
hl.env("XCURSOR_SIZE", "24")
hl.env("GTK_THEME", "Tokyonight-Dark")
hl.env("GDK_SCALE", "1.5")
hl.env("QT_SCALE_FACTOR", "0.8")
hl.env("QT_QPA_PLATFORM", "wayland")
hl.env("QT_QPA_PLATFORMTHEME", "qt5ct")
hl.env("QT_STYLE_OVERRIDE", "kvantum")

------------------
---- MONITORS ----
------------------

hl.monitor({ output = "DP-1", mode = "3840x2160@120.0", position = "0x1200", scale = 1.25 })
hl.monitor({ output = "DP-2", mode = "3840x2160@144.0", position = "3072x0", scale = 1.0, transform = 3 })
hl.monitor({ output = "eDP-1", mode = "2880x1920@60", position = "0x0", scale = 1.5 })

---------------------
---- MY PROGRAMS ----
---------------------

local terminal = "foot"
local fileManager = "thunar"
local menu = "rofi -show drun -show-icons -theme /home/probird5/.config/rofi/theme.rasi"

-------------------
---- AUTOSTART ----
-------------------

hl.on("hyprland.start", function()
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    hl.exec_cmd("gentoo-pipewire-launcher")
    hl.exec_cmd("~/.config/waybar/launch-waybar.sh")
    hl.exec_cmd("hypridle")
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")
end)

-- Preserve old `exec`, which ran on every config reload.
hl.exec_cmd("/home/probird5/.config/hypr/scripts/wallpaper.sh")

-----------------------
---- LOOK AND FEEL ----
-----------------------

hl.config({
    ecosystem = {
        no_update_news = true,
    },

    xwayland = {
        force_zero_scaling = true,
    },

    cursor = {
        no_hardware_cursors = 1,
    },

    general = {
        gaps_in = 5,
        gaps_out = 20,
        border_size = 1,

        col = {
            active_border = { colors = { "rgba(7aa2f7ee)", "rgba(bb9af7ee)" }, angle = 45 },
            inactive_border = "rgba(414868aa)",
        },

        resize_on_border = false,
        allow_tearing = false,
        layout = "master",
    },

    decoration = {
        rounding = 1,
        active_opacity = 1.0,
        inactive_opacity = 1.0,

        blur = {
            enabled = true,
            size = 3,
            passes = 1,
            vibrancy = 0.1696,
        },
    },

    animations = {
        enabled = false,
    },

    dwindle = {
        preserve_split = true,
        force_split = 2,
    },

    master = {
        new_status = "master",
        mfact = 0.55,
        orientation = "left",
    },

    scrolling = {
        column_width = 1.0,
        follow_focus = true,
    },

    misc = {
        disable_hyprland_logo = true,
        vrr = 0,
    },

    input = {
        kb_layout = "us",
        kb_variant = "",
        kb_model = "",
        kb_options = "",
        kb_rules = "",
        follow_mouse = 1,
        sensitivity = 0,

        touchpad = {
            natural_scroll = true,
            clickfinger_behavior = true,
            disable_while_typing = true,
        },
    },
})

hl.curve("myBezier", { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.05 } } })
hl.animation({ leaf = "windows", enabled = true, speed = 7, bezier = "myBezier" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 7, bezier = "default", style = "popin 80%" })
hl.animation({ leaf = "border", enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "borderangle", enabled = true, speed = 8, bezier = "default" })
hl.animation({ leaf = "fade", enabled = true, speed = 7, bezier = "default" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 6, bezier = "default" })

hl.device({
    name = "epic-mouse-v1",
    sensitivity = -0.5,
})

---------------------
---- KEYBINDINGS ----
---------------------

local mainMod = "SUPER"

local function layout_msg_if(layout, message)
    return hl.dsp.exec_cmd("~/.config/hypr/scripts/layoutmsg-if-layout.sh " .. layout .. " " .. message)
end

hl.bind(mainMod .. " + RETURN", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + SHIFT + Q", hl.dsp.exit())
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + V", hl.dsp.exec_cmd([=[cliphist list | rofi -dmenu -theme /home/probird5/.config/rofi/theme.rasi -p "Clipboard" | cliphist decode | wl-copy]=]))
hl.bind(mainMod .. " + SHIFT + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + P", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + N", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + B", layout_msg_if("dwindle", "togglesplit"))
hl.bind("Print", hl.dsp.exec_cmd([=[grim -g "$(slurp -d)" - | satty -f -]=]))

hl.bind(mainMod .. " + SHIFT + R", hl.dsp.exec_cmd("hyprctl reload"))
hl.bind(mainMod .. " + W", hl.dsp.exec_cmd("~/.config/hypr/scripts/wallpaper.sh"))
hl.bind(mainMod .. " + T", hl.dsp.exec_cmd("~/.config/foot/toggle-transparency.sh"))

hl.bind("SUPER + d", hl.dsp.window.fullscreen())
hl.bind(mainMod .. " + M", hl.dsp.window.fullscreen({ mode = "maximized" }))

hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "l" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "r" }))
hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "u" }))
hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "d" }))
hl.bind(mainMod .. " + H", hl.dsp.focus({ direction = "l" }))
hl.bind(mainMod .. " + L", hl.dsp.focus({ direction = "r" }))
hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = "u" }))
hl.bind(mainMod .. " + J", hl.dsp.focus({ direction = "d" }))

-- Master layout keybindings (DWM-style). Kept in addition to the focus binds above.
hl.bind(mainMod .. " + J", layout_msg_if("master", "cyclenext"))
hl.bind(mainMod .. " + K", layout_msg_if("master", "cycleprev"))
hl.bind(mainMod .. " + SHIFT + RETURN", layout_msg_if("master", "swapwithmaster"))
hl.bind(mainMod .. " + I", layout_msg_if("master", "addmaster"))
hl.bind(mainMod .. " + U", layout_msg_if("master", "removemaster"))
hl.bind(mainMod .. " + SHIFT + J", layout_msg_if("master", "swapnext"))
hl.bind(mainMod .. " + SHIFT + K", layout_msg_if("master", "swapprev"))
hl.bind(mainMod .. " + F", layout_msg_if("master", "orientationleft"))
hl.bind(mainMod .. " + SHIFT + F", layout_msg_if("master", "orientationtop"))

for i = 1, 10 do
    local key = i % 10
    hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

hl.bind(mainMod .. " + SHIFT + left", hl.dsp.window.move({ direction = "l" }))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.move({ direction = "r" }))
hl.bind(mainMod .. " + SHIFT + up", hl.dsp.window.move({ direction = "u" }))
hl.bind(mainMod .. " + SHIFT + down", hl.dsp.window.move({ direction = "d" }))
hl.bind(mainMod .. " + SHIFT + H", hl.dsp.window.move({ direction = "l" }))
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.window.move({ direction = "r" }))
hl.bind(mainMod .. " + SHIFT + K", hl.dsp.window.move({ direction = "u" }))
hl.bind(mainMod .. " + SHIFT + J", hl.dsp.window.move({ direction = "d" }))

hl.bind(mainMod .. " + CTRL + left", hl.dsp.window.resize({ x = -20, y = 0, relative = true }))
hl.bind(mainMod .. " + CTRL + right", hl.dsp.window.resize({ x = 20, y = 0, relative = true }))
hl.bind(mainMod .. " + CTRL + up", hl.dsp.window.resize({ x = 0, y = -20, relative = true }))
hl.bind(mainMod .. " + CTRL + down", hl.dsp.window.resize({ x = 0, y = 20, relative = true }))
hl.bind(mainMod .. " + CTRL + H", hl.dsp.window.resize({ x = -40, y = 0, relative = true }))
hl.bind(mainMod .. " + CTRL + L", hl.dsp.window.resize({ x = 40, y = 0, relative = true }))
hl.bind(mainMod .. " + CTRL + K", hl.dsp.window.resize({ x = 0, y = -40, relative = true }))
hl.bind(mainMod .. " + CTRL + J", hl.dsp.window.resize({ x = 0, y = 40, relative = true }))

hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl s +5%"), { repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl s 5%-"), { repeating = true })
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("pamixer -i 5"), { repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("pamixer -d 5"), { repeating = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("pamixer --default-source -m"))
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("pamixer -t"))
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"))
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"))
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"))
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"))

--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

hl.window_rule({
    match = { title = "^(Picture-in-Picture)$" },
    float = true,
    pin = true,
    move = { "67%", "72%" },
    size = { "33%", "28%" },
})

hl.window_rule({
    match = { class = "^steam_app\\d+$" },
    fullscreen = true,
    monitor = "DP-1",
    workspace = "10",
})

hl.window_rule({
    match = { class = "^(?i)thunar$" },
    float = true,
    center = true,
    size = { 1000, 700 },
})

hl.window_rule({
    match = { class = "^(librewolf)$", title = "^(Picture-in-Picture)$" },
    float = true,
    pin = true,
    size = { 800, 450 },
})

hl.workspace_rule({ workspace = "1", monitor = "DP-1", default = true })
hl.workspace_rule({ workspace = "2", monitor = "DP-1", layout = "scrolling" })
hl.workspace_rule({ workspace = "3", monitor = "DP-1" })
hl.workspace_rule({ workspace = "4", monitor = "DP-1" })
hl.workspace_rule({ workspace = "5", monitor = "DP-1" })
hl.workspace_rule({ workspace = "10", monitor = "DP-1", no_border = true, no_rounding = true })
hl.workspace_rule({ workspace = "6", monitor = "DP-2", default = true, layout = "dwindle" })
hl.workspace_rule({ workspace = "7", monitor = "DP-2", layout = "dwindle" })
hl.workspace_rule({ workspace = "8", monitor = "DP-2" })
hl.workspace_rule({ workspace = "9", monitor = "DP-2" })
