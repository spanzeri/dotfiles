local has_dap, dap = pcall(require, "dap")
local has_dapui, dapui = pcall(require, "dapui")
local log = require("sam.logging")

if not has_dap then
	log.warn("DAP not installed. Debugging functionalities won't be enabled")
	return
end


-- TODO: Add a better json decoder
-- require("dap.ext.vscode").json_decode = ...
--

require("dap.ext.vscode").load_launchjs()

vim.fn.sign_define("DapBreakpoint", { text = "○", texthl = "", linehl = "", numhl = "" })
vim.fn.sign_define("DapStopped", { text = "●", texthl = "", linehl = "", numhl = "" })
vim.fn.sign_define("DapLogPoint", { text = "📝", texthl = "", linehl = "", numhl = "" })
vim.fn.sign_define("DapBreakpointRejected", { text = "ⓧ", texthl = "", linehl = "", numhl = "" })
vim.fn.sign_define("DapBreakpointCondition", { text = "🔍", texthl = "", linehl = "", numhl = "" })

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

local codelldb_last = {}

dap.configurations.cpp = {
	{
		name = "Launch file",
		type = "codelldb",
		request = "launch",
		program = function()
			codelldb_last.cmd = codelldb_last.cmd or vim.fn.getcwd() .. "/"
			codelldb_last.cmd = vim.fn.input({
                prompt = "Executable path: ",
                default = codelldb_last.cmd,
                completion = "file" })

            local args = vim.split(codelldb_last.cmd, " ", { trimempty = true })

            if #args == 0 then
                return nil
            end
            if not vim.fn.executable(args[1]) then
                vim.notify("File not found or not executable", vim.log.levels.ERROR)
                return nil
            end

            local exe_path = table.remove(args, 1)
            codelldb_last.args = args
			return exe_path
		end,
		cwd = "${workspaceFolder}",
        args = function() return codelldb_last.args end,
		stopOnEntry = false,
	},
    {
        name = "Attach to Process",
        type = "cpp",
        request = "attach",
        pid = require("dap.utils").pick_process,
        args = {},
    }
}

dap.configurations.c = dap.configurations.cpp
dap.configurations.rust = dap.configurations.cpp
dap.configurations.zig = dap.configurations.cpp

dap.adapters.godot = {
	type = "server",
	host = "127.0.0.1",
	port = 6006,
}

dap.configurations.gdscript = {
	{
		launch_game_instance = false,
		launch_scene = false,
		name = "Launch scene",
		project = "${workspaceFolder}",
		request = "launch",
		type = "godot",
	},
}

dap.listeners.after.event_initialized["dapui_config"] = function()
	dapui.open()
end

dap.listeners.before.event_terminated["dapui_config"] = function()
	dapui.close()
end

dap.listeners.before.event_exited["dapui_config"] = function()
	dapui.close()
end
