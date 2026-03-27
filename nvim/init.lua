--[[
███████╗ █████╗ ███╗   ███╗███████╗    ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
██╔════╝██╔══██╗████╗ ████║██╔════╝    ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
███████╗███████║██╔████╔██║███████╗    ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
╚════██║██╔══██║██║╚██╔╝██║╚════██║    ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
███████║██║  ██║██║ ╚═╝ ██║███████║    ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝╚══════╝    ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝
--]]

-- Use space as leader
vim.g.mapleader = " "
vim.g.maplocalleader = " "

require 'config.options'    -- Neovim options setup
require 'config.lazy'       -- Plugin manager
require 'config.commands'   -- Custom commands
require 'config.remaps'     -- Key bindings

vim.cmd.colorscheme "miniautumn"
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
