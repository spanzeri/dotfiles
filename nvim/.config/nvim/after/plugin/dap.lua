--[[ DAP configuration ]]

local has_dap, dap = pcall(require, "dap")
if not has_dap then
	return
end

-- If available, use overseer parser as it supports comments
local dap_ext_vscode = require("dap.ext.vscode")
local has_overseer, _ = pcall(require, "overseer")
if has_overseer then
	dap_ext_vscode.json_decode = require("overseer.json").decode
end

vim.fn.sign_define("DapBreakpoint", { text = "", texthl = "", linehl = "", numhl = "" })
vim.fn.sign_define("DapBreakpointCondition", { text = "", texthl = "", linehl = "", numhl = "" })
vim.fn.sign_define("DapStopped", { text = "", texhl = "Error" })

dap.adapters.nlua = function(callback, config)
	callback { type = "server", host = config.host, port = config.port }
end

dap.configurations.lua = {
	{
		type = "nlua",
		request = "attach",
		name = "Attach to running neovim instance",
		host = function()
			return "127.0.0.1"
		end,
		port = function()
			return "54231"
		end,
	},
}

local is_windows = vim.loop.os_uname().sysname:find "Windows" and true or false
local codelldb_cmd = is_window and "codelldb.cmd" or "codelldb"

dap.adapters.codelldb = {
	type = "server",
	port = "${port}",
	executable = {
		command = vim.fn.stdpath("data") .. "/mason/bin/" .. codelldb_cmd,
		args = { "--port", "${port}" },
	},
}

dap.adapters.cppdbg = dap.adapters.codelldb

dap.configurations.cpp = {
	{
		name = "Launch file",
		type = "codelldb",
		request = "launch",
		program = function()
			codelldb_last_exe_path_ = codelldb_last_exe_path_ or vim.fn.getcwd() .. "/"
			codelldb_last_exe_path_ = vim.fn.input("Executable path: ", codelldb_last_exe_path_, "file")
			return codelldb_last_exe_path_
		end,
		cwd = "${workspaceFolder}",
		stopOnEntry = false,
	},
}

dap.configurations.c = dap.configurations.cpp
dap.configurations.rust = dap.configurations.cpp
dap.configurations.zig = dap.configurations.cpp

-- Keymap

local dapnmap = function(lhs, rhs, desc)
	if desc then
		desc = "[DAP] " .. desc
	end

	vim.keymap.set("n", lhs, rhs, { silent = true, desc = desc })
end

local dapui = require("dapui")

dapnmap("<F5>", dap.continue, "terminate")
dapnmap("<S-F5>", dap.terminate, "terminate")
dapnmap("<M-S-F5>", dap.restart, "restart")
dapnmap("<S-F10>", dap.step_back, "step back")
dapnmap("<F11>", dap.step_into, "step into")
dapnmap("<F10>", dap.step_over, "step over")
dapnmap("<S-F11>", dap.step_out, "step out")

-- Alternative mappings not using F keys
dapnmap("<leader>dc", dap.continue, "[c]ontinue")
dapnmap("<leader>dt", dap.terminate, "[t]erminate")
dapnmap("<leader>dr", dap.restart, "[r]estart")
dapnmap("<leader>db", dap.step_back, "step back")
dapnmap("<leader>di", dap.step_into, "step [i]nto")
dapnmap("<leader>ds", dap.step_over, "[s]tep over")
dapnmap("<leader>do", dap.step_out, "step [o]ut")
dapnmap("<leader>du", dapui.toggle, "[u]i toggle")

dapnmap("<leader>db", dap.toggle_breakpoint, "toggle [b]reakpoint")
dapnmap("<leader>dB", function()
	dap.set_breakpoint(vim.fn.input "[DAP] Condition > ")
end, "set conditonal [b]reakpoint")

dapnmap("<leader>de", require("dapui").eval, "[e]val")
dapnmap("<leader>dE", function()
	require("dapui").eval(vim.fn.input "[DAP] Expression > ")
end, "eval [E]xpression")


-- UI

vim.api.nvim_create_user_command("DapUiToggle", dapui.toggle, {})

dap.listeners.after.event_initialized["dapui_config"] = function()
	dapui.open()
end

dap.listeners.before.event_terminated["dapui_config"] = function()
	dapui.close()
end

dap.listeners.before.event_exited["dapui_config"] = function()
	dapui.close()
end
