-- =============================================================================
-- Options =============================================================================
vim.o.number            = true
vim.o.relativenumber    = true
vim.o.mouse             = 'a'                       -- Enable mouse
vim.o.signcolumn        = 'yes:1'
vim.o.undofile          = true                      -- Use undo file
vim.o.undodir           = vim.fn.stdpath('data') .. '/undodir'
vim.o.showmatch         = true                      -- Show matching paren on insertion
vim.o.list              = true                      -- Display whitespace characters (see below)
vim.o.listchars         = 'tab:» ,trail:·,nbsp:␣,lead:·'
vim.o.inccommand        = 'split'                   -- Preview substitutions
vim.o.colorcolumn       = '81,121'
vim.o.autoread          = true                      -- Reload files on changes
vim.o.confirm           = true                      -- Ask for confirmation on certain operations (e.g. save before close)
vim.o.numberwidth       = 4                         -- Minimum number width size is 4 (up to 9999 without moving)

vim.o.scrolloff         = 8                         -- Keep some space above/below cursor
vim.o.sidescrolloff     = 8                         -- Keep some space left/right of the cursor

vim.o.tabstop           = 4
vim.o.softtabstop       = 4
vim.o.shiftwidth        = 4
vim.o.shiftround        = true
vim.o.expandtab         = true
vim.o.smartindent       = true
vim.o.autoindent        = true

vim.o.ignorecase        = true
vim.o.smartcase         = true

vim.o.splitright        = true                      -- Make sure new split opens below and right
vim.o.splitbelow        = true

vim.o.completeopt       = "menuone,noselect,fuzzy,nosort" -- Completion options
vim.o.showmode          = false                     -- Do not show the mode, instead have it in statusline
vim.o.pumheight         = 10                        -- Popup menu height
vim.o.pumblend          = 10                        -- Popup menu transparency
vim.o.winblend          = 0                         -- Floating window transparency
vim.o.conceallevel      = 0                         -- Do not hide markup
vim.o.concealcursor     = ""                        -- Do not hide cursorline in markup
vim.o.synmaxcol         = 300                       -- Syntax highlighting limit

vim.o.cmdheight         = 0                         -- Collapse command line when not typing commands

local odin_error_format = '%f(%l:%c) %t%*[^:]: %m,%f(%l:%c) %m'
local jai_error_format = '%f:%l\\,%c: %t%*[^:]: %m'
vim.o.errorformat = vim.o.errorformat .. ',' .. odin_error_format .. ',' .. jai_error_format

-- Jai: auto-set the make command from the OS compiler + project build file
local jai_group = vim.api.nvim_create_augroup('SamConfig-Jai', { clear = true })
vim.api.nvim_create_autocmd('FileType', {
    pattern  = 'jai',
    group    = jai_group,
    callback = function(args)
        local compiler = vim.loop.os_uname().sysname == 'Linux' and 'jai-linux' or 'jai'
        local cwd      = vim.fn.getcwd()
        local build_file
        if vim.fn.filereadable(cwd .. '/first.jai') == 1 then
            build_file = 'first.jai'
        elseif vim.fn.filereadable(cwd .. '/build.jai') == 1 then
            build_file = 'build.jai'
        end
        if build_file then
            vim.bo[args.buf].makeprg = compiler .. ' ' .. build_file
        end
    end,
})

