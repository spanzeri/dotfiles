return {
    -- {
    --     "rose-pine/neovim",
    --     name = "rose-pine",
    --     lazy = false,
    --     config = function()
    --         require("rose-pine").setup({
    --             styles = {
    --                 italic = false,
    --                 transparency = true,
    --             },
    --         })
    --         vim.cmd("colorscheme rose-pine")
    --     end,
    -- },

    {
        "ribru17/bamboo.nvim",
        lazy = false,
        priority = 1000,
        config = function()
            require("bamboo").setup {
                transparent = true,
                code_style = {
                    comments = { italic = false },
                    conditionals = { italic = false },
                    namespaces = { italic = false },
                    parameters = { italic = false },
                },
            }
            require("bamboo").load()
        end,
    },

    {
        "folke/trouble.nvim",
        event = "BufEnter",
        config = function()
            local trouble = require("trouble")
            trouble.setup()

            vim.keymap.set(
                "n",
                "<leader>ed",
                function() trouble.toggled("document_diagnostics") end,
                { desc = "[e]rror [d]ocument" })
            vim.keymap.set(
                "n",
                "<leader>ew",
                function() trouble.toggle("workspace_diagnostics") end,
                { desc = "[e]rror [w]orkspace" })
            vim.keymap.set(
                "n",
                "<leader>el",
                function() trouble.toggle("loclist") end,
                { desc = "[e]rror [l]ist" })
        end,
    },

    {
        "folke/todo-comments.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        event = "BufEnter",
        opts = {
            highlight = {
                pattern = [[.*([@]<(KEYWORDS)(\(.*\))?)\s*:]],
                keyword = "bg",
            },
        },
    },

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

    {
        "folke/zen-mode.nvim",
        config = true,
        event = "VeryLazy",
    },

    { "tpope/vim-sleuth", event = "VeryLazy" },
    { "tpope/vim-repeat", event = "VeryLazy" },

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
