--[[ Remap utility functions ]]

local M = {}

local set_keymap = function(mode, args)
	if #args == 3 then
		vim.keymap.set(mode, args[1], args[2], args[3])
	else
		local rhs = table.remove(args, 2)
		local lhs = table.remove(args, 1)
		vim.keymap.set(mode, lhs, rhs, args)
	end
end

M.nmap = function(args)
	set_keymap("n", args)
end

M.imap = function(args)
	set_keymap("i", args)
end

M.xmap = function(args)
	set_keymap("x", args)
end

return M
