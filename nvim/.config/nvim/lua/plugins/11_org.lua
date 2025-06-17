return {
    {
        "dhruvasagar/vim-table-mode",
        event = "VeryLazy",
        config = function()
            vim.api.nvim_create_autocmd("FileType", {
                pattern = { "org", "markdown" },
                group = vim.api.nvim_create_augroup("TableModeCustom", { clear = true }),
                callback = function()
                    vim.b.table_mode_corner = "+"
                end,
            })
            vim.keymap.set("n", "<leader>ott", "<cmd>TableModeToggle<cr>", { desc = "Toggle Table Mode" })
            vim.keymap.set("n", "<leader>otr", "<cmd>TableModeRealign<cr>", { desc = "Realign Table Mode" })
        end,
    },

    {
        "nvim-orgmode/orgmode",
        ft = { "org" },
        opts = {
            org_hide_emphasis_markers = true,
            org_startup_folded = "content",
        },
    },

    -- Telescope integration for orgmode
    -- {
    --     "nvim-orgmode/telescope-orgmode.nvim",
    --     event = "VeryLazy",
    --     dependencies = {
    --         "nvim-orgmode/orgmode",
    --         "nvim-telescope/telescope.nvim",
    --     },
    --     config = function()
    --         require("telescope").load_extension("orgmode")
    --
    --         local has_wk, which_key = pcall(require, "which-key")
    --         if has_wk then
    --             which_key.add { "<leader>so", group = "[S]earch [o]rgmode" }
    --         end
    --
    --         vim.keymap.set("n", "<leader>sor", require("telescope").extensions.orgmode.refile_heading,
    --             { desc = "[S]earch [o]rgmode [r]efile heading" })
    --         vim.keymap.set("n", "<leader>soh", require("telescope").extensions.orgmode.search_headings,
    --             { desc = "[S]earch [o]rgmode [h]eadings" })
    --         vim.keymap.set("n", "<leader>soi", require("telescope").extensions.orgmode.insert_link,
    --             { desc = "[S]earch [o]rgmode [i]nsert link" })
    --     end,
    -- },
    --
    -- Roam plugin for orgmode
    {
        "chipsenkbeil/org-roam.nvim",
        tag = "0.1.1",
        event = "VeryLazy",
        dependencies = {
            "nvim-orgmode/orgmode",
        },
        config = function()
            require("org-roam").setup({
                directory = "~/orgfiles/roam/",
            })
        end
    },
}
