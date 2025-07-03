return {
    -- rustaceanvim: rust language
    {
        'mrcjkb/rustaceanvim',
        version = '^4',
        ft = { 'rust' },
        config = function()
            vim.notify('Rustacean init', vim.log.levels.INFO, {})
        end,
    },

    -- zig: zig language
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

    -- copilot: completion
    {
        "github/copilot.vim",
        event = "BufEnter",
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

    -- codecompanion: AI assistant
    {
        "olimorris/codecompanion.nvim",
        dependencies = {
            "github/copilot.vim",
            "nvim-lua/plenary.nvim",
            "nvim-treesitter/nvim-treesitter",
            "MeanderingProgrammer/render-markdown.nvim",    -- better chat rendering
            "echasnovski/mini.nvim",                        -- for mini.diff
        },
        opts = {
            strategies = {
                chat = {
                    completion_provider = "cmp",
                },
            },
            display = {
                chat = {
                    window = {
                        layout = "float",
                        height = 0.8,
                        width = 0.6,
                    },
                },
                diff = {
                    enabled = true,
                    provider = "mini_diff",
                },
            },
        },
        keys = {
            { "<leader>cc", "<cmd>CodeCompanion<cr>", desc = "Open CodeCompanion" },
            { "<leader>ct", "<cmd>CodeCompanionChat Toggle<cr>", desc = "CodeCompanion: Toggle chat" },
        },
        event = "VeryLazy",
    },

    -- Markdown preview
    {
        "MeanderingProgrammer/render-markdown.nvim",
        ft = { "markdown", "codecompanion" },
        opts = {},
    },
}
