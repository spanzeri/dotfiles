local ls = ""
local rs = ""

local color_config = {
	dark = {
		default_bg = "#212121",
		bg = "#484e54",
		fg = "#efefef",
		alt_bg = "#2f3337",
		red_bg = "#5d0002",
	},
	light = {
		default_bg = "#c3c3c3",
		bg = "#eeede7",
		fg = "#232323",
		alt_bg = "#d6d6d3",
		red_bg = "#5d0002",
	},
}

local function make_highlights()
	local colors = vim.o.background == "dark" and color_config.dark or color_config.light

	vim.api.nvim_set_hl(0, "SamSLNml", { bg = colors.bg, fg = colors.fg })
	vim.api.nvim_set_hl(0, "SamSLAlt", { bg = colors.alt_bg, fg = colors.fg })
	vim.api.nvim_set_hl(0, "SamSLRed", { bg = colors.alt_red, fg = colors.fg })
	vim.api.nvim_set_hl(0, "SamSLSepNml", { bg = colors.default_bg, fg = colors.bg })
	vim.api.nvim_set_hl(0, "SamSLSepAlt", { bg = colors.default_bg, fg = colors.alt_bg })

	-- modes
	vim.api.nvim_set_hl(0, "SamSLNormal", { bg = colors.bg, fg = colors.fg })
	vim.api.nvim_set_hl(0, "SamSLVisual", { bg = "#005500", fg = colors.fg })
	vim.api.nvim_set_hl(0, "SamSLInsert", { bg = "#664100", fg = colors.fg })
	vim.api.nvim_set_hl(0, "SamSLSepNormal", { bg = colors.default_bg, fg = colors.bg })
	vim.api.nvim_set_hl(0, "SamSLSepVisual", { bg = colors.fg, fg = "#005500" })
	vim.api.nvim_set_hl(0, "SamSLSepInsert", { bg = colors.default_bg, fg = "#664100" })
end

local function get_filetype()
	local has_devicons, devicons = pcall(require, 'nvim-web-devicons')
	local filetype = vim.bo.filetype
	if filetype == "alpha" then
		return ""
	end
	if filetype == "help" then
		return "󰍉"
	end
	if filetype == "term" then
		return ""
	end
	if has_devicons then
		return devicons.get_icon(filetype)
	end
	return filetype
end


local function get_time()
	return os.date('%H:%M')
end

local function get_date()
	return os.date('%d/%m/%Y')
end

local function get_line_info()
	return vim.bo.filetype == "alpha" and "" or "%P %l:%c"
end

local modes = {
	["n"] = "NORMAL",
	["no"] = "NORMAL",
	["v"] = "VISUAL",
	["V"] = "VISUAL LINE",
	["^V"] = "VISUAL BLOCK",
	["s"] = "SELECT",
	["S"] = "SELECT LINE",
	["i"] = "INSERT",
	["ic"] = "INSERT",
	["R"] = "REPLACE",
	["Rv"] = "VISUAL REPLACE",
	["c"] = "COMMAND",
	["cv"] = "VIM EX",
	["ce"] = "EX",
	["r"] = "PROMPT",
	["rm"] = "MOAR",
	["r?"] = "CONFIRM",
	["!"] = "SHELL",
	["t"] = "TERMINAL",
	["nt"] = "TERMINAL NORMAL",
}

local function get_mode_color(mode)
	if mode == "i" or mode == "ic" then
		return "%#SamSLSepInsert#", "%#SamSLInsert#"
	end
	if mode == "v" or mode == "V" or mode == "^V" then
		return "%#SamSLSepVisual#", "%#SamSLVisual#"
	end
	return "%#SamSLSepNormal#", "%#SamSLNormal#"
end

local function get_mode()
	local mode = vim.api.nvim_get_mode().mode
	local sep_col, col = get_mode_color(mode)
	return string.format("%s%s%s %s %s%s", sep_col, ls, col, modes[mode], sep_col, rs)
end

local function get_git_branch()
	local branch = vim.fn["FugitiveHead"]()
	return branch ~= "" and " " .. branch or ""
end

local function get_filename()
	local ft = vim.bo.filetype
	local use_name_only = ft == "alpha" or ft == "help" or ft == "term"
	return use_name_only and "%t" or "%f"
end

local function make_filename_inactive()
	return get_filename() .. " %m%r"
end

local function make_filename_active()
	local icon = get_filetype()

	return table.concat({
		"%#SamSLInvNml#", ls,
		"%#SamSLNml# ",
		get_filename(),
		" %#SamSLAlt# ",
		icon or "",
		" %m%r",
		" %#SamSLInvAlt#", rs,
		"%#SamSLNml#",
	})
end

local StatusLine = {
	active = function()

		return table.concat({
			get_mode(),
			" ",
			make_filename_active(),
			" ",
			get_git_branch(),
			"%=",
			get_time(),
			get_date(),
			get_line_info(),
			""
		})
	end,

	inactive = function()
		return table.concat({
			"%#StatusLineNL#",
			make_filename_inactive(),
			" ",
			get_line_info(),
		})
	end
}

local sl_augroup = vim.api.nvim_create_augroup("SamStatusLine", { clear = true })
local has_hl = false

vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter", "ModeChanged", "ColorSchemePre" }, {
	callback = function()
		if not has_hl then
			make_highlights()
			has_hl = true
		end
		vim.wo.statusline = StatusLine.active()
		print("Mode: " .. vim.api.nvim_get_mode().mode)
	end,
	group = sl_augroup,
	pattern = "*",
	desc = "Set statusline active",
})
vim.api.nvim_create_autocmd({ "WinLeave", "BufLeave" }, {
	callback = function()
		vim.wo.statusline = StatusLine.inactive()
	end,
	group = sl_augroup,
	pattern = "*",
	desc = "Set statusline inactive",
})
