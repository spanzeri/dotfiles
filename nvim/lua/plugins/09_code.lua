return {
    -- rustaceanvim: rust language
    {
        'mrcjkb/rustaceanvim',
        version = '^6',
        lazy = false,
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

--[[

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
--]]

    -- codecompanion: AI assistant
    {
        "olimorris/codecompanion.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-treesitter/nvim-treesitter",
            "MeanderingProgrammer/render-markdown.nvim",    -- better chat rendering
            "echasnovski/mini.nvim",                        -- for mini.diff
        },
        config = function(_, _)
            local providers = require("codecompanion.providers")
            require("codecompanion").setup({
                interactions = {
                    chat = {
                        adapter = {
                            name = "ollama",
                            model = "qwen3-coder:30b",
                        },
                    },
                    inline = {
                        adapter = {
                            name = "ollama",
                            model = "qwen3-coder:30b",
                        }
                    },
                    cmd = {
                        adapter = {
                            name = "ollama",
                            model = "qwen3-coder:30b",
                        }
                    },
                },
                display = {
                    diff = {
                        enabled = true,
                        provider = providers.mini_diff,
                    },
                    chat = {
                        window = {
                            width = 0.4,
                        }
                    }
                },
            })

            local ok, wk = pcall(require, "which-key")
            if ok then
                wk.add({ "<leader>i", group = "A[I]" })
            end
        end,
        init = function()
            require("nvim-treesitter.install").ensure_installed({
                "lua",
                "markdown",
                "markdown_inline",
                "yaml",
            })
        end,
        keys = {
            { "<leader>ip", "<cmd>CodeCompanion<cr>", desc = "Open CodeCompanion", mode = { "n", "v" }},
            { "<leader>ic", "<cmd>CodeCompanionChat Toggle<cr>", desc = "CodeCompanion: Toggle chat" },
            { "<leader>ia", "<cmd>CodeCompanionAction<cr>", desc = "CodeCompanion: Action" },
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
