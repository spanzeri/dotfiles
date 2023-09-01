--[[
User and auto-commands
]]

local va = vim.api

local custom_highlight_group = va.nvim_create_augroup("CustomHighlightGroup", { clear = true })

-- Highlight on yank
va.nvim_create_autocmd("TextYankPost", {
	callback = function()
		vim.highlight.on_yank()
	end,
	group = custom_highlight_group,
	pattern = "*",
})

local custom_utils_group = va.nvim_create_augroup("CustomUtilsGroup", { clear = true })

-- Ensure no plugin re-adds the o option
va.nvim_create_autocmd("BufEnter", {
	callback = function()
		vim.opt.formatoptions:remove { "o" }
		if vim.api.nvim_buf_get_option(0, "buftype") == "" then
			vim.wo.list = true
		end
	end,
	group = custom_utils_group,
	pattern = "*",
})

-- Auto-reload files that have been modified
va.nvim_create_autocmd("FocusGained,BufEnter,CursorHold,CursorHoldI", {
	callback = function()
		local fname = vim.fn.expand("%")
		if vim.loop.fs_stat(fname) then
			vim.cmd.checktime()
		end
	end,
	group = custom_utils_group,
	pattern = "*",
})
va.nvim_create_autocmd("FileChangedShellPost", {
	callback = function()
		vim.api.nvim_echo({{ "File has changed on disk. Reloading", "WarningMsg" }}, false, {})
	end,
	group = custom_utils_group,
	pattern = "*",
})

-- Trim whitespaces
-- TODO: when I finally make a plugin for project management, I should move this command and enable it on a
-- project basis on save

vim.api.nvim_create_user_command("TrimWhitespaces", [[:%s/\s\+$//e]], {})

-- Better terminal windows
local ft_augroup = vim.api.nvim_create_augroup("CustomFtCmds", { clear = true })

vim.api.nvim_create_autocmd("TermOpen", {
	callback = function()
		vim.cmd.set "filetype=term"
		vim.wo.number = false
		vim.wo.relativenumber = false
	end,
	group = ft_augroup,
})

vim.api.nvim_create_autocmd("TermClose", {
	callback = function()
		vim.wo.number = vim.o.number
		vim.wo.relativenumber = vim.o.relativenumber
	end,
	group = ft_augroup,
})
