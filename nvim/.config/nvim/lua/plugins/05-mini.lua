return {
    {
        "echasnovski/mini.nvim",
        event = "VimEnter",
        config = function()
            -- Better Around/Inside textobjects
            --
            -- Examples:
            --  - va)  - [V]isually select [A]round [)]paren
            --  - yinq - [Y]ank [I]nside [N]ext [']quote
            --  - ci'  - [C]hange [I]nside [']quote
            require("mini.ai").setup({ n_lines = 500 })

            -- Add/delete/replace surroundings (brackets, quotes, etc.)
            --
            -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
            -- - sd'   - [S]urround [D]elete [']quotes
            -- - sr)'  - [S]urround [R]eplace [)] [']
            require("mini.surround").setup()

            -- Simple and easy statusline.
            local statusline = require("mini.statusline")
            statusline.setup({ use_icons = true })

            -- You can configure sections in the statusline by overriding their
            -- default behavior. For example, here we set the section for
            -- cursor location to LINE:COLUMN
            ---@diagnostic disable-next-line: duplicate-set-field
            statusline.section_location = function()
                return "%2l:%-2v"
            end

            require("mini.align").setup()

            require("mini.trailspace").setup()

            require("mini.notify").setup()

            require("mini.bufremove").setup()
            pcall(require("which-key").add, { "<leader>b", group = "buffer" })
            vim.keymap.set("n", "<leader>bd", MiniBufremove.delete, { desc = "[b]uffer [d]elete" })
            vim.keymap.set("n", "<leader>bh", MiniBufremove.unshow, { desc = "[b]uffer [h]ide" })
        end,
    },
}
