return {
    {
        "blazkowolf/gruber-darker.nvim",
        config = function()
            require("gruber-darker").setup {
                italic = {
                    strings   = false,
                    comments  = false,
                    operators = false,
                    folds     = false,
                },
                bold = false,
                underline = false,
                undercurl = false,
                invert = {},
            }

            local yellow = "#f9de3e"
            local green = "#7bc158"
            local brown = "#9b7d46"

            vim.cmd.colorscheme "gruber-darker"

            vim.api.nvim_set_hl(0, "Normal", { bg = nil })
            vim.api.nvim_set_hl(0, "NormalNC", { bg = nil })
            vim.api.nvim_set_hl(0, "GruberDarkerYellow", { fg = yellow })
            vim.api.nvim_set_hl(0, "GruberDarkerYellowBold", { fg = yellow })
            vim.api.nvim_set_hl(0, "GruberDarkerYellowSign", { fg = yellow })
            vim.api.nvim_set_hl(0, "GruberDarkerGreen", { fg = green })
            vim.api.nvim_set_hl(0, "GruberDarkerGreenBold", { fg = green })
            vim.api.nvim_set_hl(0, "GruberDarkerGreenSign", { fg = green })
            vim.api.nvim_set_hl(0, "GruberDarkerQuartz", { fg = "#9b9e9b" })
            vim.api.nvim_set_hl(0, "GruberDarkerNiagara", { fg = "#f4f4f4" })
            vim.api.nvim_set_hl(0, "String", { fg = green })
            vim.api.nvim_set_hl(0, "GruberDarkerBrown", { fg = brown })
            vim.api.nvim_set_hl(0, "Comment", { fg = brown })

            vim.api.nvim_set_hl(0, "DiagnosticInfo", { fg = "#E88668" })
            vim.api.nvim_set_hl(0, "Whitespace", { link = "GruberDarkerBg3" })
        end,
        lazy = false,
        priority = 1000,
    },

    {
        "sainnhe/sonokai",
        lazy = false,
        priority = 1000,
        config = function()
            -- vim.g.sonokai_style = "atlantis"
            -- vim.g.sonokai_better_performance = 1
            -- vim.g.sonokai_transparent_background = 1
            -- vim.cmd "colorscheme sonokai"
        end,
    },

    -- todo-comments: Highlights for todo comments in code
    {
        "folke/todo-comments.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "folke/snacks.nvim",
        },
        event = "BufEnter",
        opts = {
            highlight = {
                pattern = [[.*([@]<(KEYWORDS)(\(.*\))?)\s*:]],
                keyword = "bg",
            },
            colors = {
                error   = { "DiagnosticError", "ErrorMsg", "#DC2626" },
                warning = { "DiagnosticWarn", "WarningMsg", "#FBBF24" },
                info    = { "DiagnosticInfo", "#2563EB" },
                hint    = { "DiagnosticHint", "#10B981" },
                default = { "Identifier", "#7C3AED" },
                test    = { "Identifier", "#FF00FF" }
            },
        },
        keys = {
            { "<leader>st", function() Snacks.picker.todo_comments() end, desc = "[s]earch [t]odo comments" },
        },
    },
}
