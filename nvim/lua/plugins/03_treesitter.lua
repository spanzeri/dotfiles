return {
    {
        "nvim-treesitter/nvim-treesitter",
        dependencies = {
            "nvim-treesitter/nvim-treesitter-textobjects",
            "nvim-treesitter/nvim-treesitter-context",
            "nvim-treesitter/nvim-treesitter-context",
        },
        build = ":TSUpdate",
        lazy = false,
        opts = {
            ensure_installed = { "c", "lua", "luadoc", "cpp", "c", "glsl" },
            ignore_install = { 'org' },
            auto_install = true,
            highlight = { enable = true },
            indent = { enable = true },

            incremental_selection = {
                enable = true,
                lookahead = true,
                keymaps = {
                    init_selection    = "<C-s>",
                    node_incremental  = "<C-n>",
                    scope_incremental = "<C-s>",
                    node_decremental  = "<M-s>",
                },
            },

            textobjects = {
                move = {
                    enable = true,
                    set_jumps = true,

                    goto_next_start = {
                        ["]p"] = "@parameter.inner",
                        ["]m"] = "@function.outer",
                        ["]]"] = "@class.outer",
                    },
                    goto_next_end = {
                        ["]M"] = "@function.outer",
                        ["]["] = "@class.outer",
                    },
                    goto_previous_start = {
                        ["[p"] = "@parameter.inner",
                        ["[m"] = "@function.outer",
                        ["[["] = "@class.outer",
                    },
                    goto_previous_end = {
                        ["[M"] = "@function.outer",
                        ["[]"] = "@class.outer",
                    },
                },

                select = {
                    enable = true,
                    lookahead = true,

                    keymaps = {
                        ["af"] = "@function.outer",
                        ["if"] = "@function.inner",

                        ["ac"] = "@conditional.outer",
                        ["ic"] = "@conditional.inner",

                        ["aa"] = "@parameter.outer",
                        ["ia"] = "@parameter.inner",

                        ["av"] = "@variable.outer",
                        ["iv"] = "@variable.inner",
                    },
                },
            },
        },
        config = function(_, opts)
            local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
            parser_config.jai = {
                install_info = {
                    url = "https://github.com/constantitus/tree-sitter-jai",
                    files = { "src/parser.c", "src/scanner.c" },
                },
                maintainers = { "@constantitus" },
            }
            vim.treesitter.language.register("jai", "jai")

            vim.filetype.add({ extension = { jai = "jai" } })

            require("nvim-treesitter.configs").setup(opts)
        end,
    },
}
