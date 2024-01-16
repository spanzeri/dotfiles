local custom_hl_group = vim.api.nvim_create_augroup("CustomHighlightGroup", { clear = true })

vim.api.nvim_create_autocmd("TextYankPost", {
	callback = function() vim.highlight.on_yank() end,
	group = custom_hl_group,
	pattern = "*",
	desc = "Highlight yanked text",
})

local is_normal_buffer = function()
	return vim.bo.buftype == "" and vim.bo.filetype ~= "help"
end

--
-- Trailing whitespaces
--

local TrailingWS = {
	match_group = "TrailingWhitespace",
}

TrailingWS.enable_hl = function(self)
	if not TrailingWS.is_enabled() or vim.fn.mode() ~= "n" then
		TrailingWS.disable_hl()
		return
	end

	if not is_normal_buffer() or TrailingWS.get_match_id() ~= nil then
		return
	end

	-- priority one so that it's higher than search but lower than anything else
	vim.fn.matchadd(TrailingWS.match_group, [[\s\+$]], 1)
	vim.fn.matchadd(TrailingWS.match_group, [[\v(^\s*\n){1}\zs(^\s*\n)*%$\n]], 1)
end

TrailingWS.disable_hl = function()
	while true do
		local match_id = TrailingWS.get_match_id()
		if not match_id or match_id <= 0 then
			break
		end
		vim.fn.matchdelete(match_id)
	end
end

TrailingWS.is_enabled = function()
	return not vim.g.ignore_trailing_whitespaces and not vim.b.ignore_trailing_whitespaces
end

TrailingWS.get_match_id = function()
	for _, match in ipairs(vim.fn.getmatches()) do
		if match.group == TrailingWS.match_group then
			return match.id
		end
	end
end


TrailingWS.trim_whitespaces_eol = function()
	for index, line in ipairs(vim.fn.getline(1, "$")) do
		vim.fn.setline(index, vim.fn.substitute(line, [[\s\+$]], "", ""))
	end
end

TrailingWS.trim_whitespaces_eof = function()
	local lines = vim.api.nvim_buf_get_lines(0, 1, -1, false)
	local last_empty = #lines
	for index = #lines, 1, -1 do
		if not lines[index]:match([[^%s*$]]) then
			break
		end
		last_empty = index
	end

	if last_empty < #lines then
		vim.api.nvim_buf_set_lines(0, last_empty, #lines, false, {})
	end
end

TrailingWS.trim_whitespaces = function()
	TrailingWS.trim_whitespaces_eol()
	TrailingWS.trim_whitespaces_eof()
end

vim.api.nvim_set_hl(0, TrailingWS.match_group, { bg = "#560D0F", ctermbg = "Red", default = true })

vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter", "InsertLeave", "TermClose" }, {
	callback = function() TrailingWS.enable_hl() end,
	group = custom_hl_group,
	pattern = "*",
	desc = "Enable trailing whitespace highlights",
})

vim.api.nvim_create_autocmd({ "WinLeave", "BufLeave", "InsertEnter", "TermOpen" }, {
	callback = function() TrailingWS.disable_hl() end,
	group = custom_hl_group,
	pattern = "*",
	desc = "Disable trailing whitespace highlights",
})

vim.api.nvim_create_user_command("TrimWhitespaces", TrailingWS.trim_whitespaces, {})
vim.api.nvim_create_user_command("TrimWhitespacesEOL", TrailingWS.trim_whitespaces_eol, {})
vim.api.nvim_create_user_command("TrimWhitespacesEOF", TrailingWS.trim_whitespaces_eof, {})

-- Use the same group for all utils
local utils_augroup = vim.api.nvim_create_augroup("SamUtils", { clear = true })

--
-- Auto-reload files on change
--

vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
	callback = function()
		if vim.loop.fs_stat(vim.fn.expand("%")) then
			vim.cmd.checktime()
		end
	end,
	group = utils_augroup,
	pattern = "*",
	desc = "Check for file modifications outside neovim",
})

vim.api.nvim_create_autocmd("FileChangedShellPost", {
	callback = function()
		vim.notify("File changed on disk, reloading", vim.log.levels.INFO, {})
	end,
	group = utils_augroup,
	pattern = "*",
	desc = "Notify user when a file has changed and gets reloaded",
})

--
-- Save files on compilation
--

vim.api.nvim_create_autocmd("QuickFixCmdPost", {
	callback = function()
		if vim.fn.mode() == "n" then
			vim.cmd [[silent! wa]]
		end
	end,
	group = utils_augroup,
	pattern = "*",
	desc = "Save files on compilation",
})

--
-- Clean up terminal buffers
--
vim.api.nvim_create_autocmd("TermOpen", {
	callback = function()
		vim.cmd.set "filetype=term"
		vim.wo.number = false
		vim.wo.relativenumber = false
	end,
	group = utils_augroup,
	desc = "Set terminal filetype and disable numbers",
})

vim.api.nvim_create_autocmd("TermClose", {
	callback = function()
		vim.wo.number = vim.o.number
		vim.wo.relativenumber = vim.o.relativenumber
	end,
	group = utils_augroup,
	desc = "Restore settings on terminal close",
})

--
-- Create scratch buffers
--
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

--
-- Better terminal and help drawing
--
vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter", "BufWinEnter", "InsertEnter" }, {
	callback = function()
		if vim.bo.buftype == "terminal" or vim.bo.buftype == "prompt" or vim.bo.filetype == "help" then
			vim.wo.number = false
			vim.wo.list = false
		else
			vim.wo.number = true
			vim.wo.list = true
		end
	end,
	group = utils_augroup,
	desc = "Remove line number and whitechars from terminal and help buffers",
})


--
-- DAP
--

local has_dapui, dapui = pcall(require, "dapui")
if has_dapui then
	vim.api.nvim_create_user_command("DapUiToggle", dapui.toggle, {})
end
