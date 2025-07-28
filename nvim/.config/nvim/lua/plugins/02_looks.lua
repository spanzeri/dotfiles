return {
    -- gruber-darker: colorscheme
    -- {
    --     "blazkowolf/gruber-darker.nvim",
    --     config = function()
    --         require("gruber-darker").setup {
    --             italic = {
    --                 strings   = false,
    --                 comments  = false,
    --                 operators = false,
    --                 folds     = false,
    --             },
    --         }
    --
    --         local yellow = "#f9de3e"
    --         local green = "#7bc158"
    --         local brown = "#9b7d46"
    --
    --         vim.cmd.colorscheme "gruber-darker"
    --         vim.api.nvim_set_hl(0, "GruberDarkerYellow", { fg = yellow })
    --         vim.api.nvim_set_hl(0, "GruberDarkerYellowBold", { fg = yellow })
    --         vim.api.nvim_set_hl(0, "GruberDarkerYellowSign", { fg = yellow })
    --         vim.api.nvim_set_hl(0, "GruberDarkerGreen", { fg = green })
    --         vim.api.nvim_set_hl(0, "GruberDarkerGreenBold", { fg = green })
    --         vim.api.nvim_set_hl(0, "GruberDarkerGreenSign", { fg = green })
    --         vim.api.nvim_set_hl(0, "GruberDarkerQuartz", { fg = "#9b9e9b" })
    --         vim.api.nvim_set_hl(0, "GruberDarkerNiagara", { fg = "#f4f4f4" })
    --         vim.api.nvim_set_hl(0, "String", { fg = green })
    --         vim.api.nvim_set_hl(0, "GruberDarkerBrown", { fg = brown })
    --         vim.api.nvim_set_hl(0, "Comment", { fg = brown })
    --         -- vim.api.nvim_set_hl(0, "Normal", { bg = nil })
    --         -- vim.api.nvim_set_hl(0, "NormalNC", { bg = nil })
    --         -- vim.api.nvim_set_hl(0, "VertSplit", { bg = nil })
    --         -- vim.api.nvim_set_hl(0, "Float", { bg = nil })
    --     end,
    --     lazy = false,
    --     priority = 1000,
    -- },

    {
        "cdmill/neomodern.nvim",
        opts = {
            theme = "roseprime",
            variant = "dark",
            term_colors = true,
            -- transparent = true,
        },
        config = function(_, opts)
            -- require("neomodern").setup(opts)
            -- require("neomodern").load()
        end,
        lazy = false,
        priority = 1000,
    },

    {
        "rebelot/kanagawa.nvim",
        opts = {
            theme = "dragon",
            background = {
                dark = "dragon",
                light = "lotus",
            },
            commentStyle = { italic = false, },
            keywordStyle = { italic = false, },
            overrides = function(colors)
                return {
                    Whitespace = { fg = "#3A3937" },
                }
            end,
        },
        config = function(_, opts)
            require("kanagawa").setup(opts)
            vim.cmd.colorscheme "kanagawa"
        end,
        lazy = false,
        priority = 1000,
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
        },
        keys = {
            { "<leader>st", function() Snacks.picker.todo_comments() end, desc = "[s]earch [t]odo comments" },
        },
    },

    -- gitsigns: Gutter symbols
    {
        "lewis6991/gitsigns.nvim",
        event = "BufEnter",
        opts = {
            signs = {
                add = { text = "+" },
                change = { text = "~" },
                delete = { text = "_" },
                topdelete = { text = "‾" },
                changedelete = { text = "~" },
            },
        },
    },
}
