return {
    {
        "hrsh7th/nvim-cmp",
        event = "InsertEnter",
        dependencies = {
            {
                "L3MON4D3/LuaSnip",
                dependencies = {
                    {
                        "rafamadriz/friendly-snippets",
                        config = function()
                            require("luasnip.loaders.from_vscode").lazy_load()
                        end,
                    },
                }
            },
            "saadparwaiz1/cmp_luasnip",
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-path",
            "hrsh7th/cmp-buffer",
            "onsails/lspkind.nvim",
        },
        config = function()
            require("lspkind").init({})

            local cmp = require("cmp")
            local luasnip = require("luasnip")

            cmp.setup({
                snippet = {
                    expand = function(args)
                        luasnip.lsp_expand(args.body)
                    end,
                },
                completion = {
                    completeopt = "menu,menuone,noselect",
                },
                mapping = cmp.mapping.preset.insert({
                    ["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
                    ["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
                    ["<C-b>"] = cmp.mapping.scroll_docs(-4),
                    ["<C-f>"] = cmp.mapping.scroll_docs(4),
                    ["<C-y>"] = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Insert, select = true }),
                    ["<C-c>"] = cmp.mapping.close(),
                    ["<C-space>"] = cmp.mapping.complete({}),
                    ["<C-l>"] = cmp.mapping(function(fallback)
                        if luasnip.expand_or_locally_jumpable() then
                            luasnip.expand_or_jump()
                        else
                            fallback()
                        end
                    end, { "i", "s" }),
                    ["<C-h>"] = cmp.mapping(function(fallback)
                        if luasnip.locally_jumpable(-1) then
                            luasnip.jump(-1)
                        else
                            fallback()
                        end
                    end, { "i", "s" }),
                }),
                sources = {
                    { name = "nvim_lsp" },
                    { name = 'org' },
                    { name = "path" },
                    { name = "buffer", keyword_length = 4 },
                },
            })
        end,
    },

    -- {
    --     'saghen/blink.cmp',
    --     dependencies = 'rafamadriz/friendly-snippets',
    --     version = 'v0.*',
    --     opts = {
    --         keymap = { preset = 'default' },
    --         appearance = {
    --             use_nvim_cmp_as_default = true,
    --             nerd_font_variant = 'mono'
    --         },
    --
    --         sources = {
    --             default = { 'lsp', 'path', 'snippets', 'buffer' },
    --         },
    --
    --         signature = { enabled = true },
    --
    --         documentation = {
    --             auto_show = true,
    --         },
    --     },
    -- },
}
