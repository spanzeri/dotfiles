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

vim.cmd [[colorscheme miniautumn]]
vim.api.nvim_set_hl(0, "Normal", { bg = nil })
vim.api.nvim_set_hl(0, "DiagnosticError", { fg = "#C80000" })
vim.api.nvim_set_hl(0, "DiagnosticWarn", { fg = "#C6C628" })
vim.api.nvim_set_hl(0, "DiagnosticNote", { fg = "#00BB00" })

