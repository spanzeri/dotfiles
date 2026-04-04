return {
    {
        "hl-comments",
        dependencies = { "nvim-treesitter/nvim-treesitter" },
        dev = true,
        event = "BufEnter",
        config = function()
            require('hl-comments').setup()
        end,
    },
}
