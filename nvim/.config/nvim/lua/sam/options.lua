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
opt.shiftround = true
opt.expandtab = true
opt.smartindent = true
opt.autoindent = true
opt.cindent = true
opt.wrap = true

-- Formatting options: in normal mode, o and O do not add comments
opt.formatoptions:remove("to")
opt.formatoptions:append("rl")
vim.opt_local.formatoptions:remove("to")
vim.opt_local.formatoptions:append("rl")

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
	tab   =  "→ ",
	trail = "~",
}
opt.list = true

