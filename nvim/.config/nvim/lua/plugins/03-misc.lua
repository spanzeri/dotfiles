return {
    {
        'ramojus/mellifluous.nvim',
        lazy = false,
        priority = 1000,
        init = function()
            require("mellifluous").setup({
                transparent_background = {
                    telescope = false,
                },
            })
            vim.cmd.colorscheme("mellifluous")
            vim.cmd("hi Normal guibg=NONE")
        end,
    },

    { "tpope/vim-sleuth", event = "VeryLazy" },
    { "tpope/vim-repeat", event = "VeryLazy" },

    {
        "folke/which-key.nvim",
        event = "VimEnter",
        config = function()
            require("which-key").setup()
            require("which-key").register({
                ["<leader>c"] = { name = "code" },
                ["<leader>x"] = { name = "execute" },
                ["g"] = { name = "goto" },
            })
        end
    },

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

    {
        "lukas-reineke/indent-blankline.nvim",
        main = "ibl",
        event = "BufEnter",
        opts = {
            exclude = {
                buftypes = { "nofile", "terminal", "quickfix", "prompt" },
                filetypes = { "help", "TelescopePrompt", "TelescopeResult", "man", "lazy", "lspinfo" },
            },
            scope = { enabled = true },
        },
    },

    {
        "mbbill/undotree",
        event = "VeryLazy",
    },

    {
        "yorickpeterse/nvim-window",
        config = true,
        event = "VimEnter",
        keys = {
            { "<leader>j", function() require("nvim-window").pick() end, desc = "[j]ump to window" },
        },
    },

    {
        "rcarriga/nvim-notify",
        event = "VeryLazy",
        config = true,
    },
}
