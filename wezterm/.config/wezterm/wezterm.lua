local wezterm = require 'wezterm'
local config = wezterm.config_builder()
local act = wezterm.action

-- GUI
config.window_background_opacity = 0.9
config.window_decorations = 'INTEGRATED_BUTTONS|RESIZE'
config.window_padding = { left=8, right=8, top=8, bottom=8 }

-- Font
config.font = wezterm.font_with_fallback {
	"Hurmit Nerd Font",
	"Monaco",
	"DejaVu Sans Mono",
}
config.font_size = 11

-- Keybindings
config.leader = { key='a', mods='CTRL', timeout_milliseconds=1000 }
config.keys = {
	{ key = 'R', mods = 'LEADER|SHIFT', action = act.ReloadConfiguration },
	{ key = '|', mods = 'LEADER|SHIFT', action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },
	{ key = '~', mods = 'LEADER|SHIFT', action = act.SplitVertical { domain = 'CurrentPaneDomain' } },
}

return config
