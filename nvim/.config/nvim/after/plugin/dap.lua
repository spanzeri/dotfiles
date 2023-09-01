--[[ DAP configuration ]]

local has_dap, dap = pcall(require, "dap")
if not has_dap then
	return
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

dap.adapters.codelldb = {
	type = "server",
	port = "${port}",
	executable = {
		command = vim.fn.stdpath("data") .. "/mason/bin/codelldb.cmd",
		args = { "--port", "${port}" },
	},
}

dap.configurations.cpp = {
	{
		name = "Launch file",
		type = "codelldb",
		request = "launch",
		program = function()
			return vim.fn.input("Executable path: ", vim.fn.getcwd() .. "/", "file")
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

dapnmap("<F5>", dap.continue, "continue")
dapnmap("<S-F5>", dap.terminate, "terminate")
dapnmap("<M-S-F5>", dap.restart, "restart")
dapnmap("<S-F10>", dap.step_back, "step back")
dapnmap("<F11>", dap.step_into, "step into")
dapnmap("<F10>", dap.step_over, "step over")
dapnmap("<S-F11>", dap.step_out, "step out")

dapnmap("<leader>db", dap.toggle_breakpoint, "toggle [b]reakpoint")
dapnmap("<leader>dB", function()
	dap.set_breakpoint(vim.fn.input "[DAP] Condition > ")
end, "set conditonal [b]reakpoint")

dapnmap("<leader>de", require("dapui").eval, "[e]val")
dapnmap("<leader>dE", function()
	require("dapui").eval(vim.fn.input "[DAP] Expression > ")
end, "eval [E]xpression")

-- UI

local dap_ui = require("dapui")

dap_ui.setup {}

dap.listeners.after.event_initialized["dapui_config"] = function()
	dap_ui.open()
end

dap.listeners.before.event_terminated["dapui_config"] = function()
	dap_ui.close()
end

dap.listeners.before.event_exited["dapui_config"] = function()
	dap_ui.close()
end
