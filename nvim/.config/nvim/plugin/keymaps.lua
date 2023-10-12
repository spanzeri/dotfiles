--[[ Basic keymaps
Keymaps we always want available, with or without plugins
]]

local remap_utils = require("utils.remap")
local nmap = remap_utils.nmap
local xmap = remap_utils.xmap
local imap = remap_utils.imap

-- Better movement with word-wrap
nmap { "k", [[v:count == 0 ? "gk" : "k"]], { expr = true, silent = true } }
nmap { "j", [[v:count == 0 ? "gj" : "j"]], { expr = true, silent = true } }

-- Ctrl+Backspace and Ctrl+Del in insert mode
imap { "<C-del>", "<C-o>dw" }
imap { "<C-BS>", "<C-o>db" }
imap { "<C-h>", "<C-o>db" } -- support for terminals that remap C-BS to C-h

-- Yank to and paste from system clipboard
xmap { "<leader>p", [["_dP]], { desc = "[p]aste and preserve register" } }
xmap { "<leader>P", [["+dP]], { desc = "[P]aste from system" } }
vim.keymap.set({ "n", "x" }, "<leader>y", [["+y]], { desc = "[y]ank to system" })
vim.keymap.set({ "n", "x" }, "<leader>Y", [["+Y]], { desc = "[Y]ank line to system" })
nmap { "<leader>p", [["+p]], { desc = "[p]aste from sytem" } }
nmap { "<leader>P", [["+P]], { desc = "[P]aste before cursor from sytem" } }

-- Diagnostic and error navigation and windows
nmap { "[d", vim.diagnostic.goto_prev, { desc = "go to previous [d]iagnostic" } }
nmap { "]d", vim.diagnostic.goto_prev, { desc = "go to next [d]iagnostic" } }
nmap { "[e", vim.cmd.cprev, { desc = "go to previous [e]rror", silent = true } }
nmap { "]e", vim.cmd.cnext, { desc = "go to next [e]rror", silent = true } }
nmap { "<leader>df", vim.diagnostic.open_float, { desc = "open [d]iagnostic [f]loat" } }
nmap { "<leader>dl", vim.diagnostic.setloclist, { desc = "open [d]iagnostic [l]ist" } }
-- @TODO: error list and float
nmap { "<leader>el", function() vim.cmd.copen { count = 20 } end, { desc = "open [e]rror [l]ist" } }

-- Diff
nmap { "gh", "<cmd>diffget //2<CR>", { silent = true, desc = "diff[g]et left [h]" } }
nmap { "gl", "<cmd>diffget //3<CR>", { silent = true, desc = "diff[g]et left [l]" } }

-- Quickly execute lua stuff
nmap { "<leader>xx", "<cmd>w | so %<CR>", { desc = "save and source current lua file" } }


local builtin = require("utils.telescope_custom")

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
nmap { "<leader>st", [[:TodoTelescope]], desc = "[s]earch [t]odos"}

-- git
nmap { "<leader>sgf", builtin.git_files, desc = "[s]earch [G]it [f]iles" }
nmap { "<leader>sGb", builtin.git_branches, desc = "[s]earch [G]it [b]ranches" }
nmap { "<leader>sGc", builtin.git_commits, desc = "[s]earch [G]it [c]ommits" }

-- make
nmap { "<leader>ms", function()
	local makeprg = vim.fn.input("Make command: ", vim.bo.makeprg, "compiler")
	vim.bo.makeprg, vim.o.makeprg = makeprg
end, desc = "[m]ake program [s]election" }

nmap { "<leader>mm", "<cmd>make<CR>", desc = "[m]ake" }
