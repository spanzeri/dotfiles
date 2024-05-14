return {
    {
        "mfussenegger/nvim-dap",

        dependencies = {
            {
                "rcarriga/nvim-dap-ui",
                dependencies = { "nvim-neotest/nvim-nio" },
                opts = {},
            },
            "williamboman/mason.nvim",
            "jay-babu/mason-nvim-dap.nvim",
        },

        event = "VeryLazy",

        config = function()
            local dap = require("dap")
            local dapui = require("dapui")

            require("mason-nvim-dap").setup({
                automatic_installation = true,
                handlers = {},
            })

            require("dap.ext.vscode").load_launchjs()

            local is_windows = vim.loop.os_uname().sysname:find("Windows") and true or false
            local codelldb_cmd = is_windows and "codelldb.cmd" or "codelldb"

            dap.adapters.codelldb = {
                type = "server",
                port = "${port}",
                executable = {
                    command = vim.fn.stdpath("data") .. "/mason/bin/" .. codelldb_cmd,
                    args = { "--port", "${port}" },
                },
            }

            local exe_launch_opts = {}
            local make_launch_opts = function()
                exe_launch_opts.cmd = exe_launch_opts.cmd or vim.fn.getcwd() .. "/"
                exe_launch_opts.cmd = vim.fn.input({
                    prompt = "Command: ",
                    default = exe_launch_opts.cmd,
                    completion = "file"
                })

                local args = vim.split(exe_launch_opts.cmd, " ", { trimempty = true })
                exe_launch_opts.program = table.remove(args, 1)
                exe_launch_opts.args = args
            end
            local get_program = function()
                if exe_launch_opts.program == nil then
                    make_launch_opts()
                end
                local res = exe_launch_opts.program
                exe_launch_opts.program = nil
                return res
            end
            local get_args = function()
                if exe_launch_opts.program == nil then
                    make_launch_opts()
                end
                return exe_launch_opts.args
            end

            dap.configurations.cpp = {
                {
                    name = "Launch program",
                    type = "codelldb",
                    request = "launch",
                    program = get_program,
                    args = get_args,
                },
                {
                    name = "Attach ot process",
                    type = "codellldb",
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

            dap.listeners.after["event_initialized"]["dapui_config"] = dapui.open
            dap.listeners.before["event_terminated"]["dapui_config"] = dapui.close
            dap.listeners.before["event_exited"]["dapui_config"] = dapui.close

            local dap_ui_widgets = require("dap.ui.widgets")

            local hover_aucmd_id = nil
            dap.listeners.after["event_initialized"]["sam_dap"] = function()
                 hover_aucmd_id = vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
                    group = vim.api.nvim_create_augroup("SamDap", { clear = true }),
                    callback = dap_ui_widgets.hover,
                    desc = "Debug hover expression",
                })
            end

            local remove_hover_aucmd = function()
                if hover_aucmd_id then
                    vim.api.nvim_del_autocmd(hover_aucmd_id)
                    hover_aucmd_id = nil
                end
            end

            dap.listeners.before["event_terminated"]["sam_dap"] = remove_hover_aucmd
            dap.listeners.before["event_exited"]["sam_dap"] = remove_hover_aucmd

            pcall(require("which-key").register, { ["<leader>d"] = { name = "debug" } })

            local toggle_conditional_breakpoint = function()
                local condition = vim.fn.input({
                    prompt = "Condition: ",
                    default = "",
                })
                if condition then
                    dap.toggle_breakpoint(condition)
                end
            end


            vim.keymap.set("n", "<leader>dc", dap.continue, { desc = "[d]ebug [c]ontinue" })
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

            vim.keymap.set("n", "<F5>", dap.continue, { desc = "debug continue" })
            vim.keymap.set("n", "<S-F5>", dap.terminate, { desc = "debug terminate" })
            vim.keymap.set("n", "<M-S-F5>", dap.restart, { desc = "debug continue" })

            vim.keymap.set("n", "<F9>", dap.toggle_breakpoint, { desc = "debug toggle breakpoint" })
            vim.keymap.set("n", "<M-F9>", toggle_conditional_breakpoint, { desc = "debug toggle conditional breakpoint" })
            vim.keymap.set("n", "<F10>", dap.step_over, { desc = "debug step over" })
            vim.keymap.set("n", "<M-F10>", dap.step_back, { desc = "debug step back" })
            vim.keymap.set("n", "<F11>", dap.step_into, { desc = "debug step into" })
            vim.keymap.set("n", "<M-F11>", dap.step_out, { desc = "debug step out" })

            local eval_expr = function()
                dapui.eval(vim.fn.input("Expression: "))
            end

            vim.keymap.set("n", "<leader>du", dapui.toggle, { desc = "[d]ebug [u]i toggle" })
            vim.keymap.set("n", "<leader>de", dapui.eval, { desc = "[d]ebug [e]val under the cursor" })
            vim.keymap.set("n", "<leader>dx", eval_expr, { desc = "[d]ebug eval e[x]pression" })
        end,
    },
}
