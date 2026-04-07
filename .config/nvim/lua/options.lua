-- =============================================================================
-- Options
-- =============================================================================

vim.o.number            = true
vim.o.relativenumber    = true
vim.o.mouse             = 'a'                         -- Enable mouse
vim.o.signcolumn        = 'auto:1'
vim.o.undofile          = true                        -- Use undo file
vim.o.undodir           = vim.fn.stdpath('data') .. '/undodir'
vim.o.showmatch         = true                        -- Show matching paren on insertion
vim.o.list              = true                        -- Display whitespace characters (see below)
vim.o.listchars         = 'tab:» ,trail:·,nbsp:␣,lead:·'
vim.o.inccommand        = 'split'                     -- Preview substitutions
vim.o.colorcolumn       = '81,121'
vim.o.autoread          = true                        -- Reload files on changes
vim.o.confirm           = true                        -- Ask for confirmation on certain operations (e.g. save before close)

vim.o.scrolloff         = 8                           -- Keep some space above/below cursor
vim.o.sidescrolloff     = 8                           -- Keep some space left/right of the cursor

vim.o.tabstop           = 4
vim.o.softtabstop       = 4
vim.o.shiftwidth        = 4
vim.o.shiftround        = true
vim.o.expandtab         = true
vim.o.smartindent       = true
vim.o.autoindent        = true

vim.o.ignorecase        = true
vim.o.smartcase         = true

vim.o.splitright        = true                        -- Make sure new split opens below and right
vim.o.splitbelow        = true

vim.o.completeopt       = "menuone,noinsert,noselect" -- Completion options
vim.o.showmode          = false                       -- Do not show the mode, instead have it in statusline
vim.o.pumheight         = 10                          -- Popup menu height
vim.o.pumblend          = 10                          -- Popup menu transparency
vim.o.winblend          = 0                           -- Floating window transparency
vim.o.conceallevel      = 0                           -- Do not hide markup
vim.o.concealcursor     = ""                          -- Do not hide cursorline in markup
vim.o.synmaxcol         = 300                         -- Syntax highlighting limit

