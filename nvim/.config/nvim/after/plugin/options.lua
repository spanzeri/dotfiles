-- Line numbers
vim.opt.number = true

-- Enable mouse
vim.opt.mouse = "a"

-- Don't show mode in the command line
vim.opt.showmode = false

-- Save undo history to file
vim.opt.undofile = true
vim.opt.undodir = vim.fn.stdpath("data") .. "/undodir/"
vim.opt.swapfile = false

-- Always show signcolumn with 1 column width
vim.opt.signcolumn = "yes:1"

-- Case insensitive search unless \C or capital letters
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true

-- Decrease update time
vim.opt.updatetime = 250

-- Decrease mapped sequence wait time
-- Displays which-key pop-up sooner
vim.opt.timeoutlen = 300

-- Configure how new splits should be opened
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Show matching paren on insertion
vim.opt.showmatch = true

-- Sets how neovim will display certain white space characters in the editor.
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

-- Pseudo-transparent completion pop-up for command-line
vim.opt.pumblend = 10
vim.opt.wildmode = "longest:full"
vim.opt.wildoptions = "pum"
vim.opt.cmdheight = 1

-- Ignore some files
vim.opt.wildignore:append({ "*.o", "*~", "*.lock" })

-- UI & colors
vim.opt.termguicolors = true
vim.opt.colorcolumn = "81,111"

-- Netrw setup
vim.g.netrw_banner = 0
vim.g.netrw_liststyle = 1

-- Folds
vim.o.foldenable   = true
vim.o.foldlevel    = 99
vim.o.foldmethod   = "expr"
vim.o.foldexpr     = "v:lua.vim.treesitter.foldexpr()"
vim.o.foldtext     = ""
vim.opt.foldcolumn = "0"
vim.opt.fillchars:append({fold = " "})

-- Spelling
vim.opt.spelllang = "en"
vim.opt.spell = true

-- Quickfix: add gcc and clang formats for errors, warnings and notes

local errformat_wrapper = {
    --- @type string[]
    before = {},
    --- @type string[]
    after = {},

    --- @param fmt string
    make_str = function(fmt)
        return fmt:gsub(" ", "\\ ")
    end,

    --- @param fmt string
    append = function(self, fmt)
        self.after[#self.after + 1] = self.make_str(fmt)
        return self
    end,

    prepend = function(self, fmt)
        self.before[#self.before + 1] = self.make_str(fmt)
        return self
    end,

    set = function(self)
        vim.o.errorformat =
            table.concat(self.before, ",") ..
            "," ..
            vim.o.errorformat ..
            "," ..
            table.concat(self.after, ",")
    end,
}

errformat_wrapper
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

local qf_item_icon = {
    e = "",
    w = "",
    i = "",
    n = "󰎞",
}

local qf_highlight_ns = vim.api.nvim_create_namespace("qf_highlight")
local qf_hl_group = {
    e = "DiagnosticError",
    w = "DiagnosticWarn",
    i = "DiagnosticInfo",
    n = "DiagnosticInfo",
}
local qf_hl_filename = "qfFileName"
local qf_hl_line_col = "qfLineNr"

-- vim.api.nvim_create_autocmd("FileType", {
--     group = vim.api.nvim_create_augroup("qf_highlight_group", { clear = true }),
--     pattern = "qf",
--     callback = function()
--         vim.cmd [[syntax clear]]
--         vim.api.nvim_buf_clear_namespace(0, qf_highlight_ns, 1, -1)
--
--         local qflist = vim.fn.getqflist({ items = 0 })
--         for i, item in ipairs(qflist.items) do
--             local index = 0
--             local do_hl = function(hl, len)
--                 vim.api.nvim_buf_set_extmark(0, qf_highlight_ns, i - 1, index, {
--                     end_line = i - 1,
--                     end_col = index + len,
--                     hl_group = hl,
--                 })
--                 index = index + len
--             end
--
--             local type = string.lower(item.type)
--
--             local icon_len = (qf_item_icon[type] or " "):len()
--             local sep_len = qf_sep:len()
--
--             local icon_hl = qf_hl_group[type] or "Normal"
--             do_hl(icon_hl, icon_len + 1)
--             do_hl(qf_hl_filename, qf_fname_max_len)
--             do_hl(icon_hl, sep_len)
--             do_hl(qf_hl_line_col, qf_line_col_len)
--             -- do_hl(icon_hl, sep_len)
--             -- do_hl("Normal", #item.text)
--         end
--     end
-- })

local function improved_qf_text_line(item)
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

function ImprovedQFTextFunc(info)
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

vim.opt.quickfixtextfunc = "v:lua.ImprovedQFTextFunc"
