-- Relative line numberopt
vim.opt.number = true
vim.opt.relativenumber = true

-- Enable mouse
vim.opt.mouse = "a"

-- Don't show mode in the command line
vim.opt.showmode = false

-- Save undo history to file
vim.opt.undofile = true
vim.opt.undodir = vim.fn.stdpath("data") .. "/undodir/"
vim.opt.swapfile = false

-- Keep signcolumn on by default
vim.opt.signcolumn = "yes"

-- Case insensitive search unless \C or capital letters
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true

-- Decrease update time
vim.opt.updatetime = 250

-- Decrease mapped sequence wait time
-- Displays which-key popup sooner
vim.opt.timeoutlen = 300

-- Configure how new splits should be opened
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Show matching paren on insertion
vim.opt.showmatch = true

-- Sets how neovim will display certain whitespace characters in the editor.
vim.opt.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

-- Preview substitutions live, as you type!
vim.opt.inccommand = "split"

-- Show which line your cursor is on
vim.opt.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 10

-- Tab behaviour
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.shiftround = true
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.autoindent = true
vim.opt.wrap = true

-- Pseudo-transparent completion popup for command-line
vim.opt.pumblend = 10
vim.opt.wildmode = "longest:full"
vim.opt.wildoptions = "pum"
vim.opt.cmdheight = 1

-- Ignore some files
vim.opt.wildignore:append({ "*.o", "*~", "*.lock" })

-- UI & colors
vim.opt.termguicolors = true
vim.opt.colorcolumn = "81,121"

-- Netrw setup
vim.g.netrw_banner = 0
vim.g.netrw_liststyle = 1
