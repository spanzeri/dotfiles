--   _____                 _       _   _                 _
--  / ____|               ( )     | \ | |               (_)
-- | (___   __ _ _ __ ___ |/ ___  |  \| | ___  _____   ___ _ __ ___
--  \___ \ / _` | '_ ` _ \  / __| | . ` |/ _ \/ _ \ \ / / | '_ ` _ \
--  ____) | (_| | | | | | | \__ \ | |\  |  __/ (_) \ V /| | | | | | |
-- |_____/ \__,_|_| |_| |_| |___/ |_| \_|\___|\___/ \_/ |_|_| |_| |_|
--
-- Samuele Panzeri
--

--[[
This is my personal neovim config and constantly changing.
None of the code is good, stable, reliable or tested, so use at your own risk.

As of now, I am still learning neovim and vim, so this config might change,
get rewritten or forever forgotten.
]]

-- map leader as soon as possible so nothing maps to the wrong one
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.keymap.set({ "n", "v" }, "s", "<nop>", { silent = true, noremap = true })

-- try and run impatient
pcall(require, "impatient")

-- use lazy.nvim for plugin management
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system {
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	}
end
vim.opt.runtimepath:prepend(lazypath)

require("lazy").setup("plugins", {
	dev = {
		path = "~/nvim-plugins",
		fallback = false,
	},
	ui = {
		icons = {
			cmd = "⌘",
			config = "🛠",
			event = "📅",
			ft = "📂",
			init = "⚙",
			keys = "🗝",
			plugin = "🔌",
			runtime = "💻",
			source = "📄",
			start = "🚀",
			task = "📌",
		},
	},
	defaults = {
		lazy = true,
	},
})

