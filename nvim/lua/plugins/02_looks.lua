return {
    -- {
    --     "zenbones-theme/zenbones.nvim",
    --     -- Optionally install Lush. Allows for more configuration or extending the colorscheme
    --     -- If you don't want to install lush, make sure to set g:zenbones_compat = 1
    --     -- In Vim, compat mode is turned on as Lush only works in Neovim.
    --     dependencies = "rktjmp/lush.nvim",
    --     lazy = false,
    --     priority = 1000,
    --     config = function()
    --         vim.cmd.colorscheme('zenwritten')
    --     end
    -- },

    {
        "hl-comments",
        dev = true,
        event = "BufEnter",
        config = function()
            vim.api.nvim_set_hl(0, "Normal", { bg = nil })
            vim.api.nvim_set_hl(0, "DiagnosticError", { fg = "#C80000" })
            vim.api.nvim_set_hl(0, "DiagnosticWarn", { fg = "#DDDD10" })
            vim.api.nvim_set_hl(0, "DiagnosticNote", { fg = "#108810" })
            require('hl-comments').setup()
        end,
    },
}
