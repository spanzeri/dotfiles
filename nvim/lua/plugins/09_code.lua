return {
    -- rustaceanvim: rust language
    {
        'mrcjkb/rustaceanvim',
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
                        adapter = "ollama",
                    },
                    inline = {
                        adapter = "ollama",
                    },
                    cmd = {
                        adapter = "ollama",
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

    {
        "yetone/avante.nvim",
        build = vim.fn.has("win32") ~= 0
            and "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false"
            or "make",
        event = "VeryLazy",
        version = false,
        opts = {
            instructions_file = "AGENT.md",
            provider = "ollama",
            providers = {
                ollama = {
                    model = "qwen3.5:9b-q8_0",
                },
            },
            input = {
                provider = "snacks",
                proiver_opts = {
                    title       = "Avante Input",
                    icons       = " ",
                    placeholder = "Enter your API key..."
                }
            }
        },
        dependencies = {
            "nvim-lua/plenary.nvim",
            "MunifTanjim/nui.nvim",
        },
    },

    -- Markdown preview
    {
        "MeanderingProgrammer/render-markdown.nvim",
        ft = { "markdown", "codecompanion", "Avante" },
        opts = {},
    },
}
