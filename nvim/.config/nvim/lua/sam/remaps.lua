local log = require("sam.logging")

--- More ergonomic remap
---
--- Use: remap { "n", "<leader>h", "cmd", desc = "Description" }
local remap = function(mode, args)
	if #args == 3 then
		vim.keymap.set(mode, args[1], args[2], args[3])
	else
		local cmd = table.remove(args, 2)
		local key = table.remove(args, 1)
		vim.keymap.set(mode, key, cmd, args)
	end
end

local nmap = function(args) remap("n", args) end
local imap = function(args) remap("i", args) end
local xmap = function(args) remap("x", args) end

-- Better movement with word-wrap
nmap { "k", [[v:count == 0 ? "gk" : "k"]], expr = true, silent = true }
nmap { "j", [[v:count == 0 ? "gj" : "j"]], expr = true, silent = true }

-- Ctrl+Backspace and Ctrl+Del in insert mode
imap { "<C-del>", "<C-o>dw" }
imap { "<C-BS>", "<C-o>db" }
imap { "<C-h>", "<C-o>db" } -- support for terminals that remap C-BS to C-h

-- Yank to and paste from system clipboard
xmap { "<leader>p", [["_dP]], { desc = "[p]aste and preserve register" } }
xmap { "<leader>P", [["+dP]], { desc = "[P]aste from system" } }
remap({ "n", "x" }, { "<leader>y", [["+y]], desc = "[y]ank to system" })
remap({ "n", "x" }, { "<leader>Y", [["+Y]], desc = "[Y]ank line to system" })
nmap { "<leader>p", [["+p]], { desc = "[p]aste from sytem" } }
nmap { "<leader>P", [["+P]], { desc = "[P]aste before cursor from sytem" } }

-- Tabs
nmap { "<leader>to", "<cmd>tabnew<CR>", { desc = "[t]ab [o]pen" } }
nmap { "<leader>tc", "<cmd>tabclose<CR>", { desc = "[t]ab [c]lose" } }
nmap { "<leader>ts", "<cmd>tab split<CR>", { desc = "[t]ab [s]plit" } }
nmap { "<leader>tn", "<cmd>tabnext<CR>", { desc = "[t]ab [n]ext" } }
nmap { "<leader>tp", "<cmd>tabprevious<CR>", { desc = "[t]ab [p]revious" } }

-- Diagnostic and error navigation and windows
nmap { "[d", vim.diagnostic.goto_prev, { desc = "go to previous [d]iagnostic" } }
nmap { "]d", vim.diagnostic.goto_prev, { desc = "go to next [d]iagnostic" } }
nmap { "<leader>df", vim.diagnostic.open_float, { desc = "open [d]iagnostic [f]loat" } }
nmap { "<leader>dl", vim.diagnostic.setloclist, { desc = "open [d]iagnostic [l]ist" } }

function toggle_quickfix()
	local winid = vim.fn.getqflist({ winid = 0 }).winid
	if winid == 0 then
		vim.cmd "copen 30"
	else
		vim.cmd "cclose"
	end
end

nmap { "<leader>el", function() vim.cmd "copen 24" end, { desc = "open [e]rror [l]ist" } }
nmap { "<leader>et", toggle_quickfix, { desc = "[e]rror list [t]oggle" } }
nmap { "<leader>ee", vim.cmd.cc, { desc = "open first [e]rror", silent = true } }
nmap { "<leader>en", vim.cmd.cn, { desc = "open [e]rror [n]ext", silent = true } }
nmap { "<leader>ep", vim.cmd.cp, { desc = "open [e]rror [p]revious", silent = true } }
nmap { "[e", vim.cmd.cp, { desc = "go to previous [e]rror", silent = true } }
nmap { "]e", vim.cmd.cn, { desc = "go to next [e]rror", silent = true } }

-- Diff
nmap { "gh", "<cmd>diffget //2<CR>", { silent = true, desc = "diff[g]et left [h]" } }
nmap { "gl", "<cmd>diffget //3<CR>", { silent = true, desc = "diff[g]et left [l]" } }

-- Quickly execute lua stuff
nmap { "<leader>xx", "<cmd>w | so %<CR>", { desc = "save and source current lua file" } }

local has_ts, builtin = pcall(require, "sam.telescope_custom")
require("sam.telescope_custom")
if has_ts then
	nmap { "<leader>/", builtin.current_buffer_fuzzy_find, desc = "fuzzy search current buffer [/]" }
	nmap { "<leader>sx", builtin.builtin, desc = "[s]earch telescope builtns" }
	nmap { "<leader>sh", builtin.help_tags, desc = "[s]earch [h]elp" }
	nmap { "<leader>sf", builtin.find_files, desc = "[s]earch [f]iles" }
	nmap { "<leader>so", builtin.oldfiles, desc = "[s]earch [o]ld files" }
	nmap { "<leader>sb", builtin.buffers, desc = "[s]earch [b]uffers" }
	nmap { "<leader>sn", builtin.nvim_config, desc = "[s]earch [n]vim config files" }
	nmap { "<leader>sw", builtin.grep_string, desc = "[s]earch current [w]ord" }
	nmap { "<leader>sg", builtin.live_grep, desc = "[s]earch by [g]rep" }
	nmap { "<leader>sd", builtin.diagnostics, desc = "[s]earch [d]iagnostics" }
	nmap { "<leader>sj", builtin.jumplist, desc = "[s]earch [j]umplist" }
	nmap { "<leader>sk", builtin.keymaps, desc = "[s]earch [k]eymaps" }
	nmap { "<leader>sr", builtin.registers, desc = "[s]earch [r]egisters" }
	nmap { "<leader>se", builtin.quickfix, desc = "[s]earch [e]rrors" }
	nmap { "<leader>sp", builtin.plugin_files, desc = "[s]earch [p]lugins" }
	nmap { "<leader>sT", [[:TodoTelescope <CR>]], desc = "[s]earch [t]odos"}

	-- git
	nmap { "<leader>sgf", builtin.git_files, desc = "[s]earch [G]it [f]iles" }
	nmap { "<leader>sGb", builtin.git_branches, desc = "[s]earch [G]it [b]ranches" }
	nmap { "<leader>sGc", builtin.git_commits, desc = "[s]earch [G]it [c]ommits" }
else
	log.warn("Telescope not found")
end

-- make
nmap { "<leader>ms", function()
	local prev_makeprg = vim.bo.makeprg
	local makeprg = vim.fn.input("Make command: ", vim.bo.makeprg, "compiler")

	-- Make sure pressing esc preserves the previous makeprg
	if makeprg == "" then
		makeprg = prev_makeprg
	end

	vim.bo.makeprg, vim.o.makeprg = makeprg
end, desc = "[m]ake program [s]election" }

nmap { "<leader>mm", function() vim.cmd "make! | cw 24" end, desc = "[m]ake" }

local function make_centered_float_win_opts(width_ration, height_ratio, border)
	local width = math.floor(vim.o.columns * width_ration)
	local height = math.floor((vim.o.lines - vim.o.cmdheight) * height_ratio)
	local row = math.floor((vim.o.lines - height) / 2)
	local col = math.floor((vim.o.columns - width) / 2)
	return {
		relative = "editor",
		width = width,
		height = height,
		row = row,
		col = col,
		border = border or "rounded",
	}
end

local function open_terminal_float()
	local win = vim.fn.bufwinnr("term://*")
	if win ~= -1 then
		vim.api.nvim_set_current_win(win)
	else
		vim.api.nvim_open_win(0, true, make_centered_float_win_opts(0.8, 0.8))
		vim.cmd "terminal"
		vim.cmd "startinsert"
	end
end

nmap { "<leader>mt", open_terminal_float, desc = "[m]ake [t]erminal" }

-- Scratch buffers
nmap { "<leader>bss", "<CMD>ScratchNew<CR>", desc = "[b]uffer [s]cratch" }
nmap { "<leader>bsv", function()
	vim.cmd "vsplit"
	vim.cmd "ScratchNew"
end, desc = "[b]uffer [s]cratch [v]split" }
nmap { "<leader>bsh", function()
	vim.cmd "split"
	vim.cmd "ScratchNew"
end, desc = "[b]uffer  [s]cratch [h]split" }

-- DAP
local has_dap, dap = pcall(require, "dap")
if has_dap then
	nmap { "<F5>", dap.continue, desc = "DAP: terminate" }
	nmap { "<S-F5>", dap.terminate, desc = "DAP: terminate" }
	nmap { "<M-S-F5>", dap.restart, desc = "DAP: restart" }
	nmap { "<S-F10>", dap.step_back, desc = "DAP: step back" }
	nmap { "<F11>", dap.step_into, desc = "DAP: step into" }
	nmap { "<F10>", dap.step_over, desc = "DAP: step over" }
	nmap { "<S-F11>", dap.step_out, desc = "DAP: step out" }

	-- Alternative mappings not using F keys
	nmap { "<leader>dc", dap.continue, desc = "DAP: [c]ontinue" }
	nmap { "<leader>dt", dap.terminate, desc = "DAP: [t]erminate" }
	nmap { "<leader>dr", dap.restart, desc = "DAP: [r]estart" }
	nmap { "<leader>db", dap.step_back, desc = "DAP: step back" }
	nmap { "<leader>di", dap.step_into, desc = "DAP: step [i]nto" }
	nmap { "<leader>ds", dap.step_over, desc = "DAP: [s]tep over" }
	nmap { "<leader>do", dap.step_out, desc = "DAP: step [o]ut" }

	nmap { "<leader>db", dap.toggle_breakpoint, desc = "DAP: toggle [b]reakpoint" }
	nmap { "<leader>dB", function()
		dap.set_breakpoint(vim.fn.input "DAP: Condition > ")
	end, desc = "DAP: set conditonal [b]reakpoint" }

	local has_dapui, dapui = pcall(require, "dapui")
	if has_dapui then
		nmap { "<leader>du", dapui.toggle, desc = "DAP: [u]i toggle" }
		nmap { "<leader>de", dapui.eval, desc = "DAP: [e]val" }
		nmap { "<leader>dE", function() dapui.eval(vim.fn.input("DAP: Expression > ")) end, desc = "DAP: eval [E]xpression" }
	end
end

