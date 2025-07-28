return {
    {
        "folke/snacks.nvim",
        priority = 1000,
        lazy = false,
        opts = {
            bigfile =       { enabled = true },
            dashboard =     { enabled = true },
            debug =         { enabled = true },
            image =         {
                enabled = true,
                math = {
                    latex = {
                        font_size = "large",
                    }
                }
            },
            indent =        {
                enabled = true,
                animate = { enabled = false },
                scope = {
                    hl = "Delimiter",
                },
            },
            input =         { enabled = true },
            lazygit =       { enabled = true },
            -- notify =        { enabled = true },
            -- notifier =      { enabled = true },
            picker =        {
                enabled = true,
                main = {
                    current = true,
                },
                ui_select = true,
            },
            quickfile =     { enabled = true },
            scope =         { enabled = true },
            scratch =       { enabled = true },
            statuscolumn =  { enabled = true },
            terminal =      { enabled = true },
            words =         { enabled = true },
        },
        config = function(_, opts)
            require("snacks").setup(opts)

            local search_hidden_files = function()
                Snacks.picker.pick {
                    finder = "files",
                    hidden = true,
                    ignored = true,
                }
            end

            local search_dir = function(directory)
                return function()
                    Snacks.picker.pick {
                        finder = "files",
                        dirs = type(directory) == "string" and { directory } or directory,
                    }
                end
            end

            local search_projects = function()
                local dirs = { "~/projects", "~/explore" }
                if vim.fn.has("win32") == 1 then
                    dirs = { "D:/projects", "D:/dev", "D:/explore", "C:/projects", "C:/explore" }
                end
                print("Searching projects in: " .. vim.inspect(dirs))
                Snacks.picker.projects {
                    dev = dirs,
                }
            end

            vim.keymap.set("n", "<leader>/",  Snacks.picker.lines,      { desc = "[s]earch in current buffer" })
            vim.keymap.set("n", "<leader><space>",  Snacks.picker.smart,{ desc = "[s]earch smart" })
            vim.keymap.set("n", "<leader>sF", search_hidden_files,      { desc = "[s]earch [f]iles (including hidden)" })
            vim.keymap.set("n", "<leader>sP", search_dir(vim.fn.stdpath("data") .. "/lazy"), { desc = "[s]earch [P]lugins" })
            vim.keymap.set("n", "<leader>sb", Snacks.picker.buffers,    { desc = "[s]earch [b]uffers" })
            vim.keymap.set("n", "<leader>sc", Snacks.picker.command_history, { desc = "[s]earch [c]ommand history" })
            vim.keymap.set("n", "<leader>sf", Snacks.picker.files,      { desc = "[s]earch [f]iles" })
            vim.keymap.set("n", "<leader>sg", Snacks.picker.grep,       { desc = "[s]earch [g]rep" })
            vim.keymap.set("n", "<leader>sh", Snacks.picker.help,       { desc = "[s]earch [h]elp" })
            vim.keymap.set("n", "<leader>sk", Snacks.picker.keymaps,    { desc = "[s]earch [k]eymaps" })
            vim.keymap.set("n", "<leader>sm", Snacks.picker.man,        { desc = "[s]earch [m]an" })
            vim.keymap.set("n", "<leader>sn", search_dir(vim.fn.stdpath("config")), { desc = "[s]earch [n]eoVim config files" })
            vim.keymap.set("n", "<leader>sp", search_projects,          { desc = "[s]earch [p]rojects" })
            vim.keymap.set("n", "<leader>sr", Snacks.picker.registers,  { desc = "[s]earch [r]egisters" })
            vim.keymap.set("n", "<leader>su", Snacks.picker.undo,       { desc = "[s]earch [u]ndo" })
            vim.keymap.set("n", "<leader>svc", Snacks.picker.git_log,   { desc = "[s]earch git [c]ommits" })
            vim.keymap.set("n", "<leader>sw", Snacks.picker.grep_word,  { desc = "[s]earch current [w]ord" })
            vim.keymap.set("n", "<leader>sx", Snacks.picker.pickers,    { desc = "[s]earch picker sources" })

            pcall(require("which-key").add, { "<leader>s", group = "search" })
            pcall(require("which-key").add, { "<leader>sv", group = "git" })

            vim.keymap.set("n", "<leader>tl", Snacks.lazygit.open, { desc = "[t]erm [l]azygit" })
            vim.keymap.set("n", "<leader>tt", Snacks.terminal.toggle, { desc = "[t]erminal [o]pen" })

            pcall(require("which-key").add, { "<leader>t", group = "terminal" })
        end
    },
}
