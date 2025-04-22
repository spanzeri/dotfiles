--[[
This file contains my custom plugins and configurations.
They are loaded from the my-plugins directory.
--]]

return {
    {
        dir = vim.fn.stdpath("config") .. "/my-plugins/smp.nvim",
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
            end, { noremap = true, silent = true })

            vim.keymap.set("n", "<leader>tt", smpterm.open, { noremap = true, silent = true })
        end,
    },
}

