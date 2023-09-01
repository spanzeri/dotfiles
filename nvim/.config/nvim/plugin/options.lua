--
-- Vim options
--

local opt = vim.opt

-- Better search defaults
opt.inccommand = 'nosplit'
opt.hlsearch = false
opt.incsearch = true
opt.ignorecase = true
opt.smartcase = true

-- Line numbers
opt.number = true
opt.relativenumber = true

-- Tabs
opt.tabstop = 4
opt.softtabstop = 4
opt.shiftwidth = 4
opt.expandtab = false
opt.smartindent = true
opt.autoindent = true
opt.cindent = true
opt.wrap = true

-- Formatting options: in normal mode, o and O do not add comments
opt.formatoptions = "jcrql"
vim.bo.formatoptions = "jcrql"

-- Pseudo-trasparent completion popup for command line 
opt.pumblend = 10
opt.wildmode = "longest:full"
opt.wildoptions = "pum"
opt.cmdheight = 1

-- Ignore compile files
opt.wildignore = "__pycache__"
opt.wildignore:append { "*.o", "*~", "*.pyc", "*pycache" }
opt.wildignore:append { "Cargo.lock", "Cargo.Bazel.Lock" }

opt.showmatch = true -- show matching paren on insertion
opt.mouse = 'a' -- enable mouse
opt.scrolloff = 10 -- ensure there are always lines below the cursor
opt.belloff = "all" -- no one ever wants to hear the bell
opt.signcolumn = "yes" -- show gutter
opt.splitbelow = true -- prefer splitting below
opt.splitright = true -- prefer splitting right

-- Faster updates
opt.updatetime = 250
opt.timeout = true
opt.timeoutlen = 500

-- Backspace behaviour
opt.backspace = { "indent", "eol", "start" }

-- Better completion defaults
opt.completeopt = { "menuone", "noselect" } -- always show menu, do not select

-- Undo
opt.swapfile = false -- don't create swap files
opt.undodir = vim.fn.stdpath("data") .. "/undodir/"
opt.undofile = true -- save to an undo file in data instead

-- Basic colours
opt.termguicolors = true
opt.background = "dark"
opt.colorcolumn = "81,121"

-- Show significant whitespaces
opt.listchars = {
	tab   = " ――",
	trail = "~",
	lead  = ".",
}

-- Cursorline highlighting
-- Only on the active buffer, not at all in certain filetypes like telescope
opt.cursorline = true
local group = vim.api.nvim_create_augroup("CursorlineControl", { clear = true })
local set_cursorline = function(event, value, pattern)
	vim.api.nvim_create_autocmd(event, {
		group = group,
		pattern = pattern,
		callback = function()
			vim.opt_local.cursorline = value
		end,
	})
end
set_cursorline("WinLeave", false) -- disable on leave
set_cursorline("WinEnter", true) -- enable on enter
set_cursorline("FileType", false, "TelescopePrompt") -- always disabled filetypes

-- Use powershell on windows

if vim.fn.has('win32') == 1 then
	vim.o.shell = 'powershell'
	vim.o.shellcmdflag = '-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.Encoding]::UTF8;'
	vim.o.shellredir = '2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode'
	vim.o.shellpipe = '2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode'
	vim.o.shellquote = ''
	vim.o.shellxquote = ''
end

