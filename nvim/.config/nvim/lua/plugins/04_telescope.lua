return {
    -- fzf-native: use fzf fuzzy pattern matching in telescope
    {
        "nvim-telescope/telescope-fzf-native.nvim",
        enabled = vim.fn.executable("cmake") == 1,
        build = {
            "cmake -S . -Bbuild -DCMAKE_BUILD_TYPE=Release -DCMAKE_POLICY_VERSION_MINIMUM=3.5",
            "cmake --build build --config Release",
            "cmake --install build --prefix build",
        },
    },

    -- telescope: picker
    {
        "nvim-telescope/telescope.nvim",

        dependencies = {
            "nvim-telescope/telescope-fzf-native.nvim",
            "nvim-telescope/telescope-ui-select.nvim",
        },

        cmd = "Telescope",
        event = "VimEnter",

        config = function(opts, _)
            local ts = require("telescope")
            ts.setup({
                defaults = {
                    winblend = 10,
                    sorting_strategy = "ascending",
                    layout_config = {
                        prompt_position = "top",
                    },
                    shorten_path = true,
                },
                pickers = {
                    colorscheme = {
                        enable_preview = true,
                    },
                },
                extensions = {
                    ["ui-select"] = { require("telescope.themes").get_dropdown() },
                },
            })

            ts.load_extension("fzf")
            ts.load_extension("ui-select")

            local builtin = require("telescope.builtin")

            vim.keymap.set("n", "<leader>/", builtin.current_buffer_fuzzy_find, { desc = "fuzzy search current buffer [/]" })
            vim.keymap.set("n", "<leader>sx", builtin.builtin, { desc = "[s]earch telescope builtns" })
            vim.keymap.set("n", "<leader>sh", builtin.help_tags, { desc = "[s]earch [h]elp" })
            vim.keymap.set("n", "<leader>sf", builtin.find_files, { desc = "[s]earch [f]iles" })
            vim.keymap.set("n", "<leader>sF", function()
                builtin.find_files({ no_ignore = true })
            end, { desc = "[s]earch [f]iles" })
            vim.keymap.set("n", "<leader>so", builtin.oldfiles, { desc = "[s]earch [o]ld files" })
            vim.keymap.set("n", "<leader>sb", builtin.buffers, { desc = "[s]earch [b]uffers" })
            vim.keymap.set("n", "<leader>sn", function()
                builtin.find_files({ cwd = vim.fn.stdpath("config") })
            end, { desc = "[s]earch [n]oevim config files" })
            vim.keymap.set("n", "<leader>sw", builtin.grep_string, { desc = "[s]earch current [w]ord" })
            vim.keymap.set("n", "<leader>sg", builtin.live_grep, { desc = "[s]earch by [g]rep" })
            vim.keymap.set("n", "<leader>sG", function()
                builtin.live_grep({ no_ignore = true })
            end, { desc = "[s]earch by [G]rep (don't ignore files)" })
            vim.keymap.set("n", "<leader>sm", builtin.marks, { desc = "[s]earch [m]arks" })
            vim.keymap.set("n", "<leader>sd", builtin.diagnostics, { desc = "[s]earch [d]iagnostics" })
            vim.keymap.set("n", "<leader>sj", builtin.jumplist, { desc = "[s]earch [j]umplist" })
            vim.keymap.set("n", "<leader>sk", builtin.keymaps, { desc = "[s]earch [k]eymaps" })
            vim.keymap.set("n", "<leader>sr", builtin.registers, { desc = "[s]earch [r]egisters" })
            vim.keymap.set("n", "<leader>se", builtin.quickfix, { desc = "[s]earch [e]rrors" })
            vim.keymap.set("n", "<leader>sp", function()
                builtin.find_files({ cwd = vim.fn.stdpath("data") .. "/lazy" })
            end, { desc = "[s]earch [p]lugins" })
            vim.keymap.set("n", "<leader>svf", builtin.git_files, { desc = "[s]earch git [f]iles" })
            vim.keymap.set("n", "<leader>svb", builtin.git_branches, { desc = "[s]earch git [b]ranches" })
            vim.keymap.set("n", "<leader>svc", builtin.git_commits, { desc = "[s]earch git [c]ommits" })

            pcall(require("which-key").add, { "<leader>s", group = "search" })
            pcall(require("which-key").add, { "<leader>sv", group = "git" })
        end,
    },
}
