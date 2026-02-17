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

vim.cmd [[colorscheme minisummer]]
vim.api.nvim_set_hl(0, "Normal", { bg = nil })
