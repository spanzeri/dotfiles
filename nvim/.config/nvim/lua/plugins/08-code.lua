return {
    {
        'mrcjkb/rustaceanvim',
        version = '^4',
        ft = { 'rust' },
        config = function()
            vim.notify('Rustacean init', vim.log.levels.INFO, {})
            vim.g.rustaceanvim = {
                server = {
                    on_attach = require("sam.lsp-config").custom_on_attach,
                },
            }
        end,
    },

    {
        "ziglang/zig.vim",
        ft = { "zig" },
        config = function(_, _)
            vim.filetype.add({
                extension = {
                    zon = "zig",
                },
            })
            vim.g.zig_fmt_autosave=false
        end
    },

    {
        "iamcco/markdown-preview.nvim",
        ft = "markdown",
        build = function() vim.fn["mkdp#util#install"]() end,
    },

    {
        "github/copilot.vim",
        event = "InsertEnter",
        init = function()
            vim.api.nvim_set_keymap("i", "<C-f>", 'copilot#Accept("CR")', { expr = true, silent = true, noremap = true })
            vim.api.nvim_set_keymap("i", "<C-t>", 'copilot#AcceptLine()', { expr = true, silent = true, noremap = true })
            vim.g.copilot_no_tab_map = true
            vim.g.copilot_assume_mapped = true
        end,
        config = function(_, _)
            vim.api.nvim_set_hl(0, "CopilotSuggestion", { fg = "#555555", italic = true })
        end,
    },

    {
        "yorickpeterse/nvim-pqf",
        event = "VeryLazy",
    },

}
