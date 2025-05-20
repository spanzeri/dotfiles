return {
    -- Oil: file manager
    {
        "stevearc/oil.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        event = "VeryLazy",
        config = function()
            require("oil").setup({
                columns = { "icon", "size", "mtime" },
                keymaps = {
                    ["<C-h>"] = false,
                    ["<M-h>"] = "actions.select_split",
                    ["<BS>"] = "actions.parent",
                },
                view_options = {
                    show_hidden = true,
                },
            })
            vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
            vim.keymap.set("n", "<leader>-", require("oil").toggle_float, { desc = "Toggle oil float" })
        end,
    },

    -- Which-Key: show shortcut prompts
    {
        "folke/which-key.nvim",
        event = "VimEnter",
        config = function()
            require("which-key").setup()
            require("which-key").add({
                { "<leader>x", group = "execute" },
                { "<leader>e", group = "errors" },
                { "<leader>m", group = "make" },
                { "g", group = "goto" },
            })
        end
    },

    -- Undotree: tree walking for undo-redo operations
    {
        "mbbill/undotree",
        event = "VeryLazy",
    },

    -- nvim-window: Fast switching over multiple windows
    {
        "yorickpeterse/nvim-window",
        config = true,
        event = "VimEnter",
        keys = {
            { "<leader>j", function() require("nvim-window").pick() end, desc = "[j]ump to window" },
        },
    },

    -- tmux: seamless nvim-tmux navigation
    {
        "aserowy/tmux.nvim",
        event = "VimEnter",
        opts = {},
    },

    -- vim-sleuth: identation auto-detection and support for .editorconfig
    { "tpope/vim-sleuth", event = "VeryLazy" },

    -- vim-repeat: better repeat behaviour
    { "tpope/vim-repeat", event = "VeryLazy" },
}
