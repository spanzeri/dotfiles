--
-- Vim options to make the default experience a little bit more pleasant
--

local set = vim.opt
local setg = vim.g

set.number = true           -- Line number
set.mouse = "a"             -- Enable mouse in every mode
set.showmode = false        -- Don't show mode in the command line
set.undofile = true         -- Save undo history
set.undodir = vim.fn.stdpath("data") .. "/unoddir"
set.swapfile = false        -- No swap file
set.signcolumn = "yes:1"    -- Always show sign column with a width of 1
set.updatetime = 250        -- Faster update time
set.timeoutlen = 300        -- Decrease mapped sequence wait
set.showmatch = true        -- Show matching paren on insertion
set.list = true             -- Display whitespace characters (see below)
set.listchars = { tab = "» ", trail = "·", nbsp = "␣", lead = "." }
set.inccommand = "split"    -- Preview substituion while typing
set.cursorline = true       -- Set which line the cursor is on
set.scrolloff = 10          -- Keep a number of lines below and above the cursor while scrolling
set.termguicolors = true    -- Enable term colors
set.colorcolumn = "81,111"  -- Highlight columns
set.wrap = true             -- Word wrap
set.wildignore:append({ "*.o", "*~", "*.lock", "~*" })
setg.netrw_banner = 0       -- Remove banner from netrw

-- Tab behaviour
set.tabstop = 4
set.softtabstop = 4
set.shiftwidth = 4
set.shiftround = true
set.expandtab = true
set.smartindent = true
set.autoindent = true

-- Smart case search with incremental highlights
set.ignorecase = true
set.smartcase = true
set.hlsearch = true

-- Open new splits below or on the right
set.splitright = true
set.splitbelow = true

-- Folds
set.foldenable = true
set.foldlevel = 99
set.foldmethod = "expr"
set.foldexpr = "v:lua.vim.treesitter.foldexpr()"
set.foldtext = ""
set.foldcolumn = "0"
set.fillchars:append({ fold = " " })

-- Spelling
set.spelllang = "en"
set.spell = true

-- Quickfix: add gcc and clang formats.
-- NOTE: The builder object is needed due to a bug in nvim when using the
-- vim.opt to set error formats.

local ErrFormat_Builder = {
    --- @type string[]
    before = {},
    --- @type string[]
    after = {},

    --- Escape the format string
    --- @param fmt string
    make_format_string = function(fmt)
        return fmt:gsub(" ", "\\ ")
    end,

    --- Add a format string before the existing ones
    --- @param fmt string
    prepend = function(self, fmt)
        self.before[#self.before + 1] = self.make_format_string(fmt)
        return self
    end,

    --- Create the error format
    set = function(self)
        vim.o.errorformat =
            table.concat(self.before, ",") .. "," .. vim.o.errorformat
    end,
}

ErrFormat_Builder
    :prepend("%f:%l:%c: %trror: %m")
    :prepend("%f:%l:%c: %tarning: %m")
    :prepend("%f:%l:%c: %tote: %m")
    :prepend("%f:%l:%c: %m")
    :prepend("%f:%l: %trror: %m")
    :prepend("%f:%l: %tarning: %m")
    :prepend("%f:%l: %tote: %m")
    :prepend("%f:%l: %m")
    :prepend("%f(%l\\,%c): %trror: %m")
    :prepend("%f(%l\\,%c): %tarning: %m")
    :prepend("%f(%l\\,%c): %tote: %m")
    :prepend("%f(%l\\,%c): %m")
    :set()

-- QuickFix improvements

local qf_item_icon = {
    e = "",
    w = "",
    i = "",
    n = "󰎞",
}

local improved_qf_text_line = function()
    local fname = vim.api.nvim_buf_get_name(item.bufnr)
    local filename = fname ~= "" and vim.fn.fnamemodify(fname, ":.") or ""

    local line = item.lnum
    local col = item.col
    local message = item.text

    local line_col
    if line == 0 then
        line_col = ""
    else
        line_col = string.format(" %d col %d ", line, col)
    end

    local prefix = ""
    local icon = qf_item_icon[item.type:lower()]
    if icon then
        prefix = icon .. "  "
    end

    if filename:len() ~= 0 then
        prefix = prefix .. filename .. " "
    end

    return string.format("%s|%s| %s", prefix, line_col, message)
end

local improved_qf_text_func = function(info)
    local query = { id = info.id, items = 0, qfbufnr = 0, context = 0 }
    local qf_list
    if info.quickfix == 1 then
        qf_list = vim.fn.getqflist(query)
    elseif info.quickfix == 0 then
        qf_list = vim.fn.getloclist(info.winid, query)
    end

    local lines = {}

    for i = info.start_idx, info.end_idx do
        local item = qf_list.items[i]
        local str = improved_qf_text_line(item)
        table.insert(lines, str)
    end

    return lines
end

vim.opt.quickfixtextfunc = "v:lua.improved_qf_text_func"

