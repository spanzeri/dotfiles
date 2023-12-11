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
va.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
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
		-- Auto-close terminal windows if exited without errors
		if vim.v.event.status == 0 then
			vim.cmd.close()
		end
	end,
	group = ft_augroup,
})

-- Make autocmds
local mk_augroup = vim.api.nvim_create_augroup("CustomMakeCmds", { clear = true })

vim.api.nvim_create_autocmd("QuickFixCmdPre", {
	callback = function()
		vim.cmd.wall()
	end,
	pattern = "*make",
	group = mk_augroup,
})

vim.api.nvim_create_user_command("ScratchNew", function()
	local bufnr = vim.api.nvim_create_buf(true, true) 
	if bufnr == 0 then
		vim.api.nvim_notify("Error creating scratch buffer", vim.log.levels.ERROR, {})
	end

	local scratch_names = {}
	local prefix = "*scratch"
	local prefix_len = #prefix
	for _, obuf in ipairs(vim.api.nvim_list_bufs()) do
		local bufname = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(obuf), ":~:.")
		if string.sub(bufname, 1, prefix_len) == prefix then
			scratch_names[bufname] = true
		end
	end

	local scratch_name = "*scratch*"
	if scratch_names[scratch_name] then
		local found_name = false
		local scratch_num = 1
		while not found_name do
			scratch_num = scratch_num + 1
			scratch_name = "*scratch_" .. scratch_num .. "*"
			found_name = not scratch_names[scratch_name]
		end
	end

	vim.api.nvim_buf_set_name(bufnr, scratch_name)
	vim.api.nvim_win_set_buf(0, bufnr)
end , {})

