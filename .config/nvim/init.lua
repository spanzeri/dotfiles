--[[
███████╗ █████╗ ███╗   ███╗███████╗    ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
██╔════╝██╔══██╗████╗ ████║██╔════╝    ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
███████╗███████║██╔████╔██║███████╗    ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
╚════██║██╔══██║██║╚██╔╝██║╚════██║    ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
███████║██║  ██║██║ ╚═╝ ██║███████║    ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝╚══════╝    ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝
--]]

vim.g.mapleader      = ' '
vim.g.maplocalleader = ' '

require('options')
require('plugins')
require('keybinds')

local command_group = vim.api.nvim_create_augroup('SamConfig-Init', { clear = true })

vim.api.nvim_create_autocmd('TextYankPost', {
    callback = function() vim.highlight.on_yank() end,
    group = command_group,
})

vim.cmd('colorscheme gruber-darker')
vim.api.nvim_set_hl(0, "Normal", { bg = nil })
vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter", "WinEnter" },
    {
        callback = function()
            vim.api.nvim_set_hl(0, "Normal", { bg = nil })
        end,
        group = vim.api.nvim_create_augroup("hl-fix", { clear = true }),
        pattern = "*",
        desc = "Ensure the background is transparent",
    })

