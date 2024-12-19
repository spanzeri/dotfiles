return {
    {
        "mfussenegger/nvim-dap",

        dependencies = {
            {
                "rcarriga/nvim-dap-ui",
                dependencies = { "nvim-neotest/nvim-nio" },
                opts = {
                    controls = {
                        icons = {
                            pause = "",
                            play = "",
                            step_into = "󰆹",
                            step_over = "",
                            step_out = "󰆸",
                            step_back = "",
                            run_last = "",
                            terminate = "",
                            disconnect = "",
                        },
                    },
                },
            },
            "williamboman/mason.nvim",
            "jay-babu/mason-nvim-dap.nvim",
            "theHamsta/nvim-dap-virtual-text",
        },

        event = "VeryLazy",

        config = function()
            local dap = require("dap")
            local dapui = require("dapui")

            require("mason-nvim-dap").setup({
                automatic_installation = true,
                handlers = {},
            })

            require("nvim-dap-virtual-text").setup()

            require("dap.ext.vscode").load_launchjs()

            local is_windows = vim.loop.os_uname().sysname:find("Windows") and true or false
            local codelldb_cmd = is_windows and "codelldb.cmd" or "codelldb"
            local cwd = nil

            local function set_dap_cwd()
                local new_dir = vim.fn.input({
                    prompt = "Directory: ",
                    default = vim.fn.getcwd(),
                    completion = "dir",
                })
                if new_dir == nil or new_dir == "" then
                    cwd = nil
                end
                cwd = new_dir
            end

            dap.adapters.codelldb = {
                type = "server",
                port = "${port}",
                executable = {
                    command = vim.fn.stdpath("data") .. "/mason/bin/" .. codelldb_cmd,
                    args = { "--port", "${port}" },
                },
            }

            if vim.fn.executable("gdb") == 1 then
                local cpptools_ext = (is_windows and ".cmd") or ""
                dap.adapters.cpptools = {
                    type = "executable";
                    name = "cpptools",
                    command = vim.fn.stdpath("data") .. "/mason/bin/OpenDebugAD7" .. cpptools_ext,
                    args = {},
                    attach = {
                        pidProperty = "processId",
                        pidSelect = "ask"
                    },
                }
            end

            local exe_launch_opts = {}
            local make_launch_opts = function()
                exe_launch_opts.cmd = exe_launch_opts.cmd or vim.fn.getcwd() .. "/"
                local new_cmd = vim.fn.input({
                    prompt = "Command: ",
                    default = exe_launch_opts.cmd,
                    completion = "file"
                })
                if new_cmd == nil or new_cmd == "" then
                    return dap.ABORT
                end
                exe_launch_opts.cmd = new_cmd

                local args = vim.split(exe_launch_opts.cmd, " ", { trimempty = true })
                exe_launch_opts.program = table.remove(args, 1)
                exe_launch_opts.args = args
                exe_launch_opts.has_program =
                    exe_launch_opts.program ~= nil and
                    vim.fn.executable(exe_launch_opts.program) == 1
            end
            local get_program = function()
                if not exe_launch_opts.has_program then
                    make_launch_opts()
                end
                if vim.fn.executable(exe_launch_opts.program) == 0 then
                    return dap.ABORT
                end
                return exe_launch_opts.program
            end
            local get_args = function()
                if not exe_launch_opts.has_program then
                    make_launch_opts()
                end
                return exe_launch_opts.args
            end

            dap.configurations.cpp = {}
            table.insert(dap.configurations.cpp, {
                name = "Launch program (codelldb)",
                type = "codelldb",
                request = "launch",
                program = get_program,
                args = get_args,
                cwd = function()
                    return cwd or "${workspaceFolder}"
                end,
            })
            if vim.fn.executable("gdb") == 1 then
                table.insert(dap.configurations.cpp, {
                    name = "Launch program (gdb)",
                    type = "cpptools",
                    request = "launch",
                    program = get_program,
                    args = get_args,
                    cwd = function()
                        return cwd or "${workspaceFolder}"
                    end,
                })
            end
            table.insert(dap.configurations.cpp, {
                name = "Attach ot process",
                type = "codellldb",
                request = "attach",
                pid = require("dap.utils").pick_process,
                args = {},
            })

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

            local dapui_open = function()
                dapui.open()
                vim.cmd("wincmd=")
            end
            local dapui_close = function()
                dapui.close()
                vim.cmd("DapVirtualTextForceRefresh")
                vim.cmd("wincmd=")
            end
            local dapui_toggle = function()
                dapui.toggle()
                vim.cmd("wincmd=")
            end

            dap.listeners.after.event_initialized["dapui_config"] = dapui_open
            dap.listeners.before.event_terminated["dapui_config"] = dapui_close
            dap.listeners.before.event_exited["dapui_config"] = dapui_close
            dap.listeners.after.disconnect["dapui_config"] = dapui_close

            local dap_ui_widgets = require("dap.ui.widgets")

            pcall(require("which-key").add, { "<leader>d", group = "debug" })

            local toggle_conditional_breakpoint = function()
                local condition = vim.fn.input({
                    prompt = "Condition: ",
                    default = "",
                })
                if condition then
                    dap.toggle_breakpoint(condition)
                end
            end

            local set_program_and_run = function()
                exe_launch_opts.has_program = false
                dap.continue()
            end

            vim.keymap.set("n", "<leader>dc", dap.continue, { desc = "[d]ebug [c]ontinue" })
            vim.keymap.set("n", "<leader>dC", set_program_and_run, { desc = "[d]ebug [C]ontinue setup" })
            vim.keymap.set("n", "<leader>dl", dap.run_last, { desc = "[d]ebug run [l]ast" })
            vim.keymap.set("n", "<leader>dt", dap.terminate, { desc = "[d]ebug [t]erminate" })
            vim.keymap.set("n", "<leader>dr", dap.restart, { desc = "[d]ebug [r]estart" })
            vim.keymap.set("n", "<leader>di", dap.step_into, { desc = "[d]ebug step [i]nto" })
            vim.keymap.set("n", "<leader>ds", dap.step_over, { desc = "[d]ebug [s]tep over" })
            vim.keymap.set("n", "<leader>dS", dap.step_back, { desc = "[d]ebug [S]tep back" })
            vim.keymap.set("n", "<leader>do", dap.step_out, { desc = "[d]ebug step [o]ut" })
            vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, { desc = "[d]ebug toggle [b]reakpoint" })
            vim.keymap.set("n", "<leader>dB", toggle_conditional_breakpoint, { desc = "[d]ebug toggle conditional [B]reakpoint" })
            vim.keymap.set("n", "<leader>dh", dap_ui_widgets.hover, { desc = "[d]ebug [h]over" })
            vim.keymap.set("n", "<leader>dw", set_dap_cwd, { desc = "[d]ebug [w]orking d]irectory" })

            vim.keymap.set("n", "<F5>", dap.continue, { desc = "debug continue" })
            vim.keymap.set("n", "<S-F5>", dap.terminate, { desc = "debug terminate" })
            vim.keymap.set("n", "<M-S-F5>", dap.restart, { desc = "debug continue" })

            vim.keymap.set("n", "<F9>", dap.toggle_breakpoint, { desc = "debug toggle breakpoint" })
            vim.keymap.set("n", "<M-F9>", toggle_conditional_breakpoint, { desc = "debug toggle conditional breakpoint" })
            vim.keymap.set("n", "<F10>", dap.step_over, { desc = "debug step over" })
            vim.keymap.set("n", "<M-F10>", dap.step_back, { desc = "debug step back" })
            vim.keymap.set("n", "<F11>", dap.step_into, { desc = "debug step into" })
            vim.keymap.set("n", "<M-F11>", dap.step_out, { desc = "debug step out" })

            local eval_at_cursor = function()
                dapui.eval(nil, { enter = true })
            end
            local eval_expr = function()
                dapui.eval(vim.fn.input("Expression: "))
            end

            vim.keymap.set("n", "<leader>du", dapui_toggle, { desc = "[d]ebug [u]i toggle" })
            vim.keymap.set("n", "<leader>de", eval_at_cursor, { desc = "[d]ebug [e]val under the cursor" })
            vim.keymap.set("n", "<leader>dx", eval_expr, { desc = "[d]ebug eval e[x]pression" })
        end,
    },
}
