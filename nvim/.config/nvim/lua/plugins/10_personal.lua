return {
    -- My own plugins
    {
        dir = vim.fn.stdpath("config") .. "/custom-plugins/smp.nvim",
        event = "VeryLazy",
        config = function()
            -- Floating terminal
            local smpterm = require "smp.term"
            smpterm.setup {}

            vim.keymap.set("n", "<leader>tl", function()
                smpterm.open {
                    command = "lazygit",
                    close_on_leave_insert = true,
                    close_on_error = true,
                }
            end, {
                noremap = true,
                silent = true,
                desc = "Open lazygit",
            })

            vim.keymap.set("n", "<leader>tt", smpterm.open, {
                noremap = true,
                silent = true,
                desc = "Open floating terminal",
            })

            local has_wk, wk = pcall(require, "which-key")
            if has_wk then
                wk.add({ "<leader>t", group = "Terminal", })
            end
        end,
    },
}

