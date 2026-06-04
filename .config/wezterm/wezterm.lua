local wezterm = require("wezterm")
local tmux = require("utils.tmux")
local theme = wezterm.plugin.require("https://github.com/neapsix/wezterm").moon

local config = wezterm.config_builder()
local act = wezterm.action

config = {
	font = wezterm.font("Maple Mono"),
	font_size = 15,
	enable_tab_bar = false,

	window_decorations = "RESIZE",
	window_padding = {
		left = 5,
		right = 0,
		top = 5,
		bottom = 0,
	},

	-- window_background_opacity = 0.9,
	window_background_opacity = 1,
	-- macos_window_background_blur = 20,

	-- set terminal to kitty
	-- fixes images and cursor blinking
	term = "xterm-kitty",
	enable_kitty_graphics = true,
	max_fps = 120,

	-- cursor
	default_cursor_style = "SteadyBlock",
	cursor_blink_ease_in = "Constant",
	cursor_blink_ease_out = "Constant",
	cursor_blink_rate = 400,

	-- cmd to tmux keymaps
	keys = {
		{ key = "Escape", mods = "", action = wezterm.action.Nop },
		{ key = "k", mods = "CMD", action = act.EmitEvent("clear_tmux_or_normal") },
		{ key = "t", mods = "CMD", action = act.EmitEvent("new_tmux_or_tab") },
		{ key = "w", mods = "CMD", action = act.EmitEvent("close_tmux_pane_or_window") },
		-- source zshrc
		{
			key = "r",
			mods = "CMD",
			action = act.Multiple({
				act.SendString("source ~/.zshrc"),
				act.SendKey({ key = "Enter", mods = " " }),
			}),
		},
	},

	-- for tilde and other macos composed keys
	send_composed_key_when_left_alt_is_pressed = true,
	-- for shortcuts using right alt
	send_composed_key_when_right_alt_is_pressed = false,

	-- color_scheme = "Catppuccin Mocha",
	-- color_scheme = "Rosé Pine Moon (Gogh)",
	colors = theme.colors(),
	window_frame = theme.window_frame(),

	-- gruvbox
	-- colors = {
	-- 	foreground = "#D4BE98",
	-- 	background = "#1D2021",
	-- 	cursor_bg = "#D4BE98",
	-- 	cursor_border = "#D4BE98",
	-- 	cursor_fg = "#1D2021",
	-- 	selection_bg = "#D4BE98",
	-- 	selection_fg = "#3C3836",
	--
	-- 	ansi = { "#1d2021", "#ea6962", "#a9b665", "#d8a657", "#7daea3", "#d3869b", "#89b482", "#d4be98" },
	-- 	brights = { "#eddeb5", "#ea6962", "#a9b665", "#d8a657", "#7daea3", "#d3869b", "#89b482", "#d4be98" },
	-- },
	-- -- solarized osaka
	-- colors = {
	-- 	foreground = "#869395",
	-- 	background = "#00141A",
	-- 	cursor_bg = "#869395",
	-- 	cursor_fg = "#10333F",
	-- 	cursor_border = "#BEEAFC",
	-- 	selection_bg = "#10333F",
	-- 	selection_fg = "#95A0A0",
	-- 	ansi = {
	-- 		"#10333F",
	-- 		"#CA4238",
	-- 		"#88982E",
	-- 		"#FFE073",
	-- 		"#AE8A2D",
	-- 		"#4689CC",
	-- 		"#C24380",
	-- 		"#519E97",
	-- 	},
	-- 	brights = {
	-- 		"#0B2732",
	-- 		"#BC5329",
	-- 		"#5C6D74",
	-- 		"#869395",
	-- 		"#6C6EC0",
	-- 		"#95A0A0",
	-- 		"#FBF6E4",
	-- 		"#ECE8D6",
	-- 	},
	-- },
}

return config
