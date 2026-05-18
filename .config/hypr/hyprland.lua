---@diagnostic disable: undefined-global

-- ========================================================
-- 🚀 HYPRLAND CONFIGURATION (LUA EDITION)
-- ========================================================

-- Variables for Easy Re-use
local mainMod = "ALT"
local secondaryMod = "SUPER"
local terminal = "ghostty"
local fileManager = "dolphin"
local menu = "wofi --show drun"
local wallpaper_script = os.getenv("HOME") .. "/.config/hypr/scripts/wallpaper_menu.sh"

-- ========================================================
-- 📦 ENVIRONMENT VARIABLES
-- ========================================================
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_THEME", "Catppuccin Mocha Mauve")
hl.env("XDG_MENU_PREFIX", "arch-")
hl.env("WALLPAPER_DIR", os.getenv("HOME") .. "/.config/backgrounds/")
hl.env("GDK_SCALE", "2")

-- ========================================================
-- 🖥️ MONITORS & LAYOUT PLACEMENT
-- ========================================================
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "auto" })
hl.monitor({ output = "HDMI-A-1", mode = "3840x2160@120", position = "auto", scale = 2 })

-- ========================================================
-- ⚙️ MAIN CONFIGURATION BLOCK
-- ========================================================
hl.config({
	-- ⌨️ Input & Devices
	input = {
		kb_layout = "gb,no",
		kb_variant = "",
		kb_model = "",
		kb_rules = "",
		numlock_by_default = true,
		repeat_delay = 200,
		repeat_rate = 35,
		follow_mouse = 1,
		sensitivity = 0.3,
		force_no_accel = true,
		touchpad = {
			natural_scroll = false,
		},
	},

	-- Per-Device Rules
	device = {
		{
			name = "epic-mouse-v1",
			sensitivity = 0,
		},
	},

	-- 🎨 Look and Feel
	general = {
		gaps_in = 5,
		gaps_out = 10,
		border_size = 3,
		col = {
			active_border = { colors = { "rgba(cba6f7bb)", "rgba(b4befebb)" }, angle = 45 },
			inactive_border = "rgba(595959aa)",
		},
		resize_on_border = true,
		allow_tearing = true,
		layout = "dwindle",
	},

	decoration = {
		rounding = 10,
		rounding_power = 2,
		active_opacity = 0.99,
		inactive_opacity = 0.99,
		fullscreen_opacity = 1,
		shadow = {
			enabled = true,
			range = 4,
			render_power = 3,
			color = "rgba(1a1a1aee)",
		},
		blur = {
			enabled = true,
			size = 3,
			passes = 1,
			vibrancy = 0.1696,
		},
	},

	-- 🎬 Animations
	-- 🎬 Animations
	animations = {
		enabled = false, -- ⚡ Set to false for instant, zero-delay snapping
		bezier = {
			easeOutQuint = { 0.23, 1, 0.32, 1 },
			easeInOutCubic = { 0.65, 0.05, 0.36, 1 },
			linear = { 0, 0, 1, 1 },
			almostLinear = { 0.5, 0.5, 0.75, 1.0 },
			quick = { 0.15, 0, 0.1, 1 },
		},
		animation = {
			{ "global", 1, 10, "default" },
			{ "border", 1, 5.39, "easeOutQuint" },
			{ "windows", 1, 4.79, "easeOutQuint" },
			{ "windowsIn", 1, 4.1, "easeOutQuint", "popin 87%" },
			{ "windowsOut", 1, 1.49, "linear", "popin 87%" },
			{ "fadeIn", 1, 1.73, "almostLinear" },
			{ "fadeOut", 1, 1.46, "almostLinear" },
			{ "fade", 1, 3.03, "quick" },
			{ "layers", 1, 3.81, "easeOutQuint" },
			{ "layersIn", 1, 4, "easeOutQuint", "fade" },
			{ "layersOut", 1, 1.5, "linear", "fade" },
			{ "fadeLayersIn", 1, 1.79, "almostLinear" },
			{ "fadeLayersOut", 1, 1.39, "almostLinear" },
			{ "workspaces", 1, 1.94, "almostLinear", "fade" },
			{ "workspacesIn", 1, 1.21, "almostLinear", "fade" },
			{ "workspacesOut", 1, 1.94, "almostLinear", "fade" },
		},
	},

	-- 📐 Layout & Misc Options
	dwindle = {
		preserve_split = true,
	},
	master = {
		new_status = "master",
	},
	misc = {
		force_default_wallpaper = 0,
		disable_hyprland_logo = true,
	},
	xwayland = {
		force_zero_scaling = true,
	},
})

-- ========================================================
-- ⚡ AUTOSTART
-- ========================================================
hl.on("hyprland.start", function()
	hl.exec_cmd("waybar & swaync & hypridle & hyprpaper &")
	hl.exec_cmd("systemctl --user start hyprpolkitagent")
	-- FIXED: Swapped 'Macchiato Light' to 'Mocha Mauve' to match env vars and prevent window transition flickering
	hl.exec_cmd("hyprctl setcursor Catppuccin Mocha Mauve 24")
	hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
end)

-- ========================================================
-- 📦 WINDOW RULES
-- ========================================================
-- 1. Browser Picture-in-Picture
hl.window_rule({
	name = "pip",
	match = { title = "^(Picture-in-Picture)$" },
	float = true,
	pin = true,
	move = { "69.5%", "4%" },
})

-- 2. Core Workspace Rules
hl.window_rule({ name = "ghostty", match = { title = "^(Ghostty)$" }, tile = true, workspace = "1" })
hl.window_rule({ name = "firefox", match = { title = "^(Firefox)$" }, tile = true, workspace = "2" })
hl.window_rule({ name = "battlenet", match = { title = "Battle.net" }, tile = true, workspace = "3" })
hl.window_rule({ name = "steam-main", match = { title = "Steam" }, tile = true, workspace = "3" })
hl.window_rule({ name = "discord", match = { title = "Discord" }, tile = true, workspace = "5" })

-- 3. Gaming Optimizations
hl.window_rule({
	name = "wow-main",
	match = { class = "^steam_app_0$", title = "^World of Warcraft$" },
	workspace = "4",
	fullscreen = true,
	tile = false,
	opaque = true,
	no_blur = true,
	no_shadow = true,
	border_size = 0,
	render_unfocused = true,
	immediate = true,
})

hl.window_rule({
	name = "arc-raiders",
	match = { class = "^steam_app_1808500$" },
	workspace = "4",
	opaque = true,
	no_blur = true,
	no_shadow = true,
	border_size = 0,
	immediate = true,
})

hl.window_rule({
	name = "steam-games-generic",
	match = { class = "^steam_app_" },
	workspace = "4",
	opaque = true,
	no_blur = true,
	no_shadow = true,
	border_size = 0,
	immediate = true,
})

-- 4. Error & Popup Handling
hl.window_rule({
	name = "wow-voice-proxy",
	match = { title = "^(.*WowVoiceProxy.*|.*World of Warcraft Voice Proxy.*)$" },
	workspace = "9 silent",
	no_initial_focus = true,
})

hl.window_rule({
	name = "wine-errors",
	match = { title = "^(.*Fatal Error.*|.*Program Error.*|.*Wine Debugger.*)$" },
	workspace = "9 silent",
	no_initial_focus = true,
})

hl.window_rule({ name = "suppress-maximize", match = { class = ".*" }, suppress_event = "maximize" })

hl.window_rule({
	name = "xwayland-fix",
	match = { class = "^$", title = "^$", xwayland = 1, fullscreen = 0 },
	no_initial_focus = true,
})

-- ========================================================
-- 🗝️ KEYBINDINGS
-- ========================================================
hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(secondaryMod .. " + space", hl.dsp.exec_cmd(menu))
hl.bind(secondaryMod .. " + Z", hl.dsp.exec_cmd(wallpaper_script))

hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + M", hl.dsp.exit())

-- NATIVE ACTIONS: Refactored out from manual hl.dispatch subshell/lambda structures
hl.bind(mainMod .. " + U", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + R", hl.dsp.layout("togglesplit"))
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ action = "toggle" }))
hl.bind(mainMod .. " + T", hl.dsp.exec_cmd("pkill waybar; waybar &"))

hl.bind(mainMod .. " + SHIFT + A", hl.dsp.exec_cmd("hyprshot -m window"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd("hyprshot -m region"))
hl.bind(mainMod .. " + SHIFT + O", hl.dsp.exec_cmd("hyprlock"))
hl.bind(mainMod .. " + SHIFT + Y", hl.dsp.exec_cmd("wlogout"))

hl.bind("CTRL + space", hl.dsp.exec_cmd("hyprctl switchxkblayout all next"))

-- 📋 MAC-STYLE CLIPBOARD (SUPER FOR COPY/PASTE/CUT)
-- hl.bind("SUPER + C", hl.dsp.send_shortcut({ mods = "CTRL", key = "C" }))
-- hl.bind("SUPER + V", hl.dsp.send_shortcut({ mods = "CTRL", key = "V" }))
-- hl.bind("SUPER + X", hl.dsp.send_shortcut({ mods = "CTRL", key = "X" }))
-- hl.bind("SUPER + A", hl.dsp.send_shortcut({ mods = "CTRL", key = "A" }))
-- hl.bind("SUPER + S", hl.dsp.send_shortcut({ mods = "CTRL", key = "S" }))

-- NATIVE DIRECTION LOOPS: Completely mapped to direct 0.55 direction endpoints
local directions = { h = "l", l = "r", k = "u", j = "d" }
for key, dir in pairs(directions) do
	hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ direction = dir }))
	hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ direction = dir }))
end

-- NATIVE WORKSPACE ARRAY: Cleaned up loops talking straight to the server layout
for i = 0, 9 do
	local workspaceString = tostring(i == 0 and 10 or i)
	hl.bind(mainMod .. " + " .. i, hl.dsp.focus({ workspace = workspaceString }))
	hl.bind(mainMod .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = workspaceString }))
end

-- NATIVE MOUSE WHEEL WORKSPACE NAVIGATION
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- NATIVE MOUSE DRAG/RESIZE INTERACTION FIX
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- HARDWARE CONTROLS
local hardware_flags = { repeating = true, locked = true }

hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"), hardware_flags)
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), hardware_flags)
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), hardware_flags)
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), hardware_flags)
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl s 10%+"), hardware_flags)
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl s 10%-"), hardware_flags)

hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })
