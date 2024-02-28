local wezterm = require 'wezterm'
local mux = wezterm.mux
local config = wezterm.config_builder()
local act = wezterm.action

local timeout_ms = 1500

-- GUI
config.window_background_opacity = 0.9
config.window_decorations = 'INTEGRATED_BUTTONS|RESIZE'
config.use_fancy_tab_bar = false
config.tab_max_width = 40
config.window_padding = { left=8, right=8, top=8, bottom=4 }
config.initial_cols = 250
config.initial_rows = 90

-- Font
config.font = wezterm.font_with_fallback {
	"Hurmit Nerd Font",
	"Monaco",
	"DejaVu Sans Mono",
}
config.font_size = 11

-- Domains
config.unix_domains = {
	{ name = 'unix' },
}

config.default_gui_startup_args = { 'connect', 'unix' }

local RenameCurrentTab = function(name)
	return wezterm.action_callback(function(window, pane)
		if name then
			window:active_tab():set_title(name)
		end
	end)
end

-- Keybindings
config.leader = { key='a', mods='CTRL', timeout_milliseconds = timeout_ms }
config.keys = {
	-- Forward ctrl+a for vim
	{ key = 'a', mods = 'LEADER', action = act.SendKey { key = 'a', mods = 'CTRL' } },

	{ key = 'g', mods = 'LEADER', action = act.Nop },

	-----------------
	-- Splits
	-----------------
	{ key = '|', mods = 'LEADER|SHIFT', action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },
	{ key = '%', mods = 'LEADER|SHIFT', action = act.SplitPane { direction = 'Right', size = { Percent = 20 } } },
	{ key = '~', mods = 'LEADER|SHIFT', action = act.SplitVertical { domain = 'CurrentPaneDomain' } },
	-- management (focus, select, move)
	{ key = 'f', mods = 'LEADER', action = act.TogglePaneZoomState },
	{ key = 'h', mods = 'LEADER', action = act.ActivatePaneDirection 'Left' },
	{ key = 'j', mods = 'LEADER', action = act.ActivatePaneDirection 'Down' },
	{ key = 'k', mods = 'LEADER', action = act.ActivatePaneDirection 'Up' },
	{ key = 'l', mods = 'LEADER', action = act.ActivatePaneDirection 'Right' },
	{ key = 'w', mods = 'LEADER', action = act.CloseCurrentPane { confirm = false } },
	-- resize
	{ key = 'r', mods = 'LEADER', action = act.ActivateKeyTable {
		name = 'pane_resize', one_shot = false, timeout_milliseconds = timeout_ms,
	} },

	-----------------
	--- Tabs
	-----------------
	{ key = 't', mods = 'LEADER|SHIFT', action = act.ShowTabNavigator },
	{ key = 't', mods = 'LEADER', action = act.ActivateKeyTable {
		name = 'tab', one_shot = false, timeout_milliseconds = timeout_ms,
	} },
	{ key = '1', mods = 'ALT', action = act.ActivateTab(0) },
	{ key = '2', mods = 'ALT', action = act.ActivateTab(1) },
	{ key = '3', mods = 'ALT', action = act.ActivateTab(2) },
	{ key = '4', mods = 'ALT', action = act.ActivateTab(3) },
	{ key = '5', mods = 'ALT', action = act.ActivateTab(4) },
	{ key = '6', mods = 'ALT', action = act.ActivateTab(5) },
	{ key = '7', mods = 'ALT', action = act.ActivateTab(6) },
	{ key = '8', mods = 'ALT', action = act.ActivateTab(7) },
	{ key = '9', mods = 'ALT', action = act.ActivateTab(8) },

	-----------------
	--- Spawn a specific tab (nvim config, btop)
	-----------------
	{ key = ',', mods = 'LEADER', action = act.Multiple {
		act.SpawnCommandInNewTab {
			cwd = os.getenv('WEZTERM_CONFIG_DIR'),
			set_environment_variables = { TERM = "screen-256color" },
			args = { '/usr/local/bin/nvim', os.getenv('WEZTERM_CONFIG_FILE') },
		},
		RenameCurrentTab('[config]'),
	} },
	{ key = '?', mods = 'LEADER|SHIFT', action = act.SpawnCommandInNewTab {
		cwd = os.getenv('HOME'),
		args = { 'btop' },
	} },
}

config.key_tables = {
	-- Tab management key table
	tab = {
		{ key = 't', action = act.SpawnTab 'CurrentPaneDomain' },
		{ key = 'w', action = act.CloseCurrentTab { confirm = false } },
		{ key = 'l', mod = 'SHIFT', action = act.MoveTabRelative(1) },
		{ key = 'h', mod = 'SHIFT', action = act.MoveTabRelative(-1) },
		{ key = 'l', action = act.ActivateTabRelative(1) },
		{ key = 'h', action = act.ActivateTabRelative(-1) },
		{ key = '1', action = act.ActivateTab(0) },
		{ key = '2', action = act.ActivateTab(1) },
		{ key = '3', action = act.ActivateTab(2) },
		{ key = '4', action = act.ActivateTab(3) },
		{ key = '5', action = act.ActivateTab(4) },
		{ key = '6', action = act.ActivateTab(5) },
		{ key = '7', action = act.ActivateTab(6) },
		{ key = '8', action = act.ActivateTab(7) },
		{ key = '9', action = act.ActivateTab(8) },
		{ key = 'Escape', action = 'PopKeyTable' },
	},
	pane_resize = {
		{ key = 'h', action = act.AdjustPaneSize { 'Left', 5 } },
		{ key = 'j', action = act.AdjustPaneSize { 'Down', 5 } },
		{ key = 'k', action = act.AdjustPaneSize { 'Up', 5 } },
		{ key = 'l', action = act.AdjustPaneSize { 'Right', 5 } },
		{ key = 'Escape', action = 'PopKeyTable' },
	},
}

-- Remember the last size for the window
-- local store
-- wezterm.on('gui-startup', function(cmd)
-- 	local tab, pane, window = mux.spanw_window
--
return config
