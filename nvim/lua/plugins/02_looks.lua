return {
    {
        "hl-comments",
        dev = true,
        lazy = false,
        config = function()
            vim.cmd.colorscheme "miniautumn"
            vim.api.nvim_set_hl(0, "DiagnosticError", { fg = "#C80000" })
            vim.api.nvim_set_hl(0, "DiagnosticWarn", { fg = "#DDDD10" })
            vim.api.nvim_set_hl(0, "DiagnosticNote", { fg = "#108810" })
            require('hl-comments').setup()
        end,
    },
}
