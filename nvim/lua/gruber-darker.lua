-- lua/gruber-darker/init.lua
-- Gruber Darker — Neovim port of the Emacs theme
-- https://github.com/rexim/gruber-darker-theme

local M = {}

M.config = {
    transparent = false,
}

function M.setup(opts)
    M.config = vim.tbl_deep_extend("force", M.config, opts or {})
end

function M.load()
    vim.cmd("hi clear")
    if vim.fn.exists("syntax_on") == 1 then vim.cmd("syntax reset") end
    vim.g.colors_name = "gruber-darker"
    vim.o.background = "dark"

    local transparent = M.config.transparent
    local c = {
        bg        = "#181818",
        bg1       = "#282828",
        bg2       = "#453d41",
        bg3       = "#52494e",
        fg        = "#efeff4",
        fg1       = "#f4f4ff",
        yellow    = "#ffdd33",
        yellow_d  = "#cc8c3c",
        green     = "#73c936",
        blue      = "#aabfdd",
        purple    = "#9e95c7",
        steel     = "#9fb4a9",
        red       = "#f43841",
        white     = "#ffffff",
        none      = "NONE",
    }

    -- When transparent, remove backgrounds from the groups that sit directly
    -- on the terminal canvas so the terminal background shows through.
    local bg        = transparent and c.none or c.bg
    local bg_float  = transparent and c.none or c.bg3
    local bg_sign   = transparent and c.none or c.bg

    local function hi(group, fg, bg_col, attrs)
        local t = { fg = fg, bg = bg_col }
        if attrs and attrs ~= "none" then
            for _, a in ipairs(vim.split(attrs, ",")) do
                local key = vim.trim(a)
                if key ~= "" and key ~= "none" then
                    t[key] = true
                end
            end
        end
        vim.api.nvim_set_hl(0, group, t)
    end

    local function link(group, target)
        vim.api.nvim_set_hl(0, group, { link = target })
    end

    -- ── Editor ──────────────────────────────────────────────────────────
    hi("Normal",        c.fg,     bg)
    hi("NormalFloat",   c.fg,     bg_float)
    hi("FloatBorder",   c.blue,   bg_float)
    hi("Cursor",        c.bg,     c.yellow)
    hi("CursorLine",    c.none,   c.bg1,    "none")
    hi("CursorLineNr",  c.yellow, c.none,   "bold")
    hi("LineNr",        c.bg3,    c.none)
    hi("SignColumn",    c.bg3,    bg_sign)
    hi("ColorColumn",   c.none,   c.bg1)
    hi("VertSplit",     c.bg3,    bg)
    hi("WinSeparator",  c.bg3,    bg)
    hi("Folded",        c.blue,   c.bg2,    "italic")
    hi("FoldColumn",    c.bg3,    bg_sign)
    hi("EndOfBuffer",   c.bg2,    c.none)
    hi("NonText",       c.bg3,    c.none)
    hi("SpecialKey",    c.bg3,    c.none)
    hi("Conceal",       c.bg3,    c.none)
    hi("Whitespace",    c.bg2,    c.none)
    hi("NormalNC",      c.fg,     c.none)
    hi("NormalFloatNC", c.fg,     bg)

    -- ── Selection / Search ──────────────────────────────────────────────
    hi("Visual",        c.none,   "#484848")
    hi("Search",        c.bg,     c.fg1)
    hi("IncSearch",     c.bg,     c.yellow)
    hi("CurSearch",     c.bg,     c.yellow)
    hi("Substitute",    c.bg,     c.red)

    -- ── UI chrome ───────────────────────────────────────────────────────
    hi("StatusLine",    c.white,   c.bg2)
    hi("StatusLineNC",  "#999999", c.bg2)
    hi("TabLine",       c.fg,      c.bg2,  "none")
    hi("TabLineFill",   c.none,    c.bg2,  "none")
    hi("TabLineSel",    c.white,   c.bg3,  "bold")
    hi("Pmenu",         c.fg,      c.bg3)
    hi("PmenuSel",      c.bg,      c.blue)
    hi("PmenuSbar",     c.none,    c.bg2)
    hi("PmenuThumb",    c.none,    c.bg3)
    hi("WildMenu",      c.bg,      c.blue)
    hi("ModeMsg",       c.fg1,     c.none, "bold")
    hi("MsgArea",       c.fg,      c.none)
    hi("MsgSeparator",  c.fg,      c.bg2)

    -- ── Diagnostics ─────────────────────────────────────────────────────
    hi("DiagnosticError",            c.red,    c.none)
    hi("DiagnosticWarn",             c.yellow, c.none)
    hi("DiagnosticInfo",             c.blue,   c.none)
    hi("DiagnosticHint",             c.steel,  c.none)
    hi("DiagnosticUnderlineError",   c.none,   c.none, "undercurl")
    hi("DiagnosticUnderlineWarn",    c.none,   c.none, "undercurl")
    hi("DiagnosticVirtualTextError", c.red,    c.none, "italic")
    hi("DiagnosticVirtualTextWarn",  c.yellow, c.none, "italic")
    hi("DiagnosticVirtualTextInfo",  c.blue,   c.none, "italic")
    hi("DiagnosticVirtualTextHint",  c.steel,  c.none, "italic")

    -- ── Misc UI ─────────────────────────────────────────────────────────
    hi("Question",   c.green,  c.none, "bold")
    hi("MoreMsg",    c.green,  c.none, "bold")
    hi("ErrorMsg",   c.red,    c.none, "bold")
    hi("WarningMsg", c.yellow, c.none, "bold")
    hi("Directory",  c.blue,   c.none, "bold")
    hi("Title",      c.blue,   c.none, "bold")
    hi("MatchParen", c.fg1,    c.bg3)
    hi("SpellBad",   c.red,    c.none, "undercurl")
    hi("SpellCap",   c.yellow, c.none, "undercurl")
    hi("SpellRare",  c.purple, c.none, "undercurl")

    -- ── Diff ────────────────────────────────────────────────────────────
    hi("DiffAdd",    c.green,  c.bg1)
    hi("DiffChange", c.blue,   c.bg1)
    hi("DiffDelete", c.red,    c.bg1)
    hi("DiffText",   c.yellow, c.bg1, "bold")
    hi("Added",      c.green,  c.none)
    hi("Changed",    c.blue,   c.none)
    hi("Removed",    c.red,    c.none)

    -- ── Syntax (classic vim) ────────────────────────────────────────────
    hi("Comment",       c.yellow_d, c.none, "italic")
    hi("String",        c.green,    c.none)
    hi("Character",     c.green,    c.none)
    hi("Number",        c.steel,    c.none)
    hi("Boolean",       c.steel,    c.none)
    hi("Float",         c.steel,    c.none)
    hi("Identifier",    c.fg1,      c.none)
    hi("Function",      c.blue,     c.none)
    hi("Keyword",       c.yellow,   c.none)
    hi("Statement",     c.yellow,   c.none)
    hi("Conditional",   c.yellow,   c.none)
    hi("Repeat",        c.yellow,   c.none)
    hi("Label",         c.yellow,   c.none)
    hi("Operator",      c.fg,       c.none)
    hi("Exception",     c.red,      c.none)
    hi("PreProc",       c.steel,    c.none)
    hi("Include",       c.steel,    c.none)
    hi("Define",        c.steel,    c.none)
    hi("Macro",         c.steel,    c.none)
    hi("PreCondit",     c.steel,    c.none)
    hi("Type",          c.steel,    c.none)
    hi("StorageClass",  c.yellow,   c.none)
    hi("Structure",     c.steel,    c.none)
    hi("Typedef",       c.steel,    c.none)
    hi("Special",       c.yellow,   c.none)
    hi("SpecialComment",c.yellow_d, c.none, "italic")
    hi("Tag",           c.blue,     c.none)
    hi("Delimiter",     c.fg,       c.none)
    hi("Debug",         c.red,      c.none)
    hi("Underlined",    c.blue,     c.none, "underline")
    hi("Error",         c.red,      c.none, "bold")
    hi("Todo",          c.bg,       c.yellow, "bold")

    -- ── Treesitter ──────────────────────────────────────────────────────
    link("@variable",              "Identifier")
    link("@variable.builtin",      "Special")
    link("@variable.parameter",    "Identifier")
    link("@variable.member",       "Identifier")
    link("@constant",              "Constant")
    link("@constant.builtin",      "Special")
    link("@constant.macro",        "Define")
    link("@module",                "Identifier")
    link("@label",                 "Label")

    link("@string",                "String")
    link("@string.escape",         "SpecialChar")
    link("@string.special",        "SpecialChar")
    link("@string.regexp",         "SpecialChar")
    link("@character",             "Character")
    link("@character.special",     "SpecialChar")
    link("@number",                "Number")
    link("@number.float",          "Float")
    link("@boolean",               "Boolean")

    link("@type",                  "Type")
    link("@type.builtin",          "Type")
    link("@type.definition",       "Typedef")
    link("@attribute",             "PreProc")

    link("@function",              "Function")
    link("@function.builtin",      "Special")
    link("@function.macro",        "Macro")
    link("@function.method",       "Function")
    link("@function.method.call",  "Function")
    link("@constructor",           "Function")

    link("@keyword",               "Keyword")
    link("@keyword.function",      "Keyword")
    link("@keyword.operator",      "Operator")
    link("@keyword.import",        "Include")
    link("@keyword.return",        "Keyword")
    link("@keyword.exception",     "Exception")
    link("@keyword.conditional",   "Conditional")
    link("@keyword.repeat",        "Repeat")
    link("@keyword.debug",         "Debug")

    link("@operator",              "Operator")
    link("@punctuation.delimiter", "Delimiter")
    link("@punctuation.bracket",   "Delimiter")
    link("@punctuation.special",   "Special")

    link("@comment",               "Comment")
    link("@comment.todo",          "Todo")
    link("@comment.error",         "Error")
    link("@comment.warning",       "WarningMsg")
    link("@comment.note",          "DiagnosticInfo")

    hi("@markup.heading",          c.blue,  c.none, "bold")
    hi("@markup.strong",           c.fg1,   c.none, "bold")
    hi("@markup.italic",           c.fg1,   c.none, "italic")
    hi("@markup.strikethrough",    c.steel, c.none, "strikethrough")
    link("@markup.raw",            "String")
    link("@markup.link",           "Underlined")
    hi("@markup.link.url",         c.blue,  c.none, "underline")
    link("@markup.list",           "Special")

    link("@tag",                   "Tag")
    link("@tag.attribute",         "Identifier")
    link("@tag.delimiter",         "Delimiter")

    -- ── LSP semantic tokens ─────────────────────────────────────────────
    link("@lsp.type.variable",    "@variable")
    link("@lsp.type.parameter",   "@variable.parameter")
    link("@lsp.type.property",    "@variable.member")
    link("@lsp.type.function",    "@function")
    link("@lsp.type.method",      "@function.method")
    link("@lsp.type.macro",       "@function.macro")
    link("@lsp.type.keyword",     "@keyword")
    link("@lsp.type.type",        "@type")
    link("@lsp.type.class",       "@type")
    link("@lsp.type.interface",   "@type")
    link("@lsp.type.enum",        "@type")
    link("@lsp.type.enumMember",  "@constant")
    link("@lsp.type.struct",      "@type")
    link("@lsp.type.namespace",   "@module")
    link("@lsp.type.string",      "@string")
    link("@lsp.type.number",      "@number")
    link("@lsp.type.boolean",     "@boolean")
    link("@lsp.type.comment",     "@comment")
    link("@lsp.type.decorator",   "@attribute")
    link("@lsp.mod.deprecated",   "DiagnosticUnderlineError")
    link("@lsp.mod.readonly",     "@constant")

    -- ── Plugin: gitsigns ────────────────────────────────────────────────
    hi("GitSignsAdd",    c.green, c.none)
    hi("GitSignsChange", c.blue,  c.none)
    hi("GitSignsDelete", c.red,   c.none)

    -- ── Plugin: nvim-tree / neo-tree ────────────────────────────────────
    link("NvimTreeNormal",         "Normal")
    hi("NvimTreeRootFolder",       c.yellow, c.none, "bold")
    hi("NvimTreeFolderName",       c.blue,   c.none)
    hi("NvimTreeOpenedFolderName", c.blue,   c.none, "bold")
    hi("NvimTreeGitDirty",         c.yellow, c.none)
    hi("NvimTreeGitNew",           c.green,  c.none)
    hi("NvimTreeGitDeleted",       c.red,    c.none)

    -- ── Plugin: Telescope ───────────────────────────────────────────────
    hi("TelescopeNormal",         c.fg,     bg)
    hi("TelescopeBorder",         c.bg3,    bg)
    hi("TelescopePromptBorder",   c.blue,   bg)
    hi("TelescopeResultsBorder",  c.bg3,    bg)
    hi("TelescopePreviewBorder",  c.bg3,    bg)
    hi("TelescopeSelectionCaret", c.yellow, c.none)
    hi("TelescopeSelection",      c.fg1,    c.bg2)
    hi("TelescopeMatching",       c.yellow, c.none, "bold")

    -- ── Plugin: Snack ───────────────────────────────────────────────────
    -- Pane backgrounds
    hi("SnacksPickerList",           c.fg,     bg)
    hi("SnacksPickerInput",          c.fg,     bg)
    hi("SnacksPickerPreview",        c.fg,     bg)
    -- Borders
    hi("SnacksPickerListBorder",     c.bg3,    bg)
    hi("SnacksPickerInputBorder",    c.blue,   bg)
    hi("SnacksPickerPreviewBorder",  c.bg3,    bg)
    -- Titles
    hi("SnacksPickerListTitle",      c.bg,     c.blue)
    hi("SnacksPickerInputTitle",     c.bg,     c.blue)
    hi("SnacksPickerPreviewTitle",   c.bg,     c.bg3)
    -- Prompt / query
    hi("SnacksPickerPrompt",         c.yellow, c.none)
    -- Results list
    hi("SnacksPickerMatch",          c.yellow, c.none, "bold")
    hi("SnacksPickerCursorLine",     c.none,   c.bg2,  "none")
    -- File / dir entries
    hi("SnacksPickerFile",           c.fg,     c.none)
    hi("SnacksPickerDir",            c.steel,  c.none)
    hi("SnacksPickerDirCursorLine",  c.fg,     c.none)
    hi("SnacksPickerPathHidden",     c.bg3,    c.none)
    -- Line / col numbers shown in results
    hi("SnacksPickerRow",            c.steel,  c.none)
    hi("SnacksPickerCol",            c.steel,  c.none)
    -- Git status letters
    hi("SnacksPickerGitStatusAdded",     c.green,  c.none)
    hi("SnacksPickerGitStatusModified",  c.blue,   c.none)
    hi("SnacksPickerGitStatusDeleted",   c.red,    c.none)
    hi("SnacksPickerGitStatusRenamed",   c.yellow, c.none)
    hi("SnacksPickerGitStatusUntracked", c.steel,  c.none)
    -- Footer / keymap hints
    hi("SnacksPickerFooter",         c.bg3,    bg)
    hi("SnacksPickerToggle",         c.yellow, c.none, "bold")
    hi("SnacksPickerKeymapDesc",     c.fg,     c.none)
    hi("SnacksPickerKeymapSep",      c.bg3,    c.none)

    -- ── Plugin: which-key ───────────────────────────────────────────────
    hi("WhichKey",          c.yellow, c.none)
    hi("WhichKeyGroup",     c.blue,   c.none)
    hi("WhichKeyDesc",      c.fg,     c.none)
    hi("WhichKeySeparator", c.bg3,    c.none)
    hi("WhichKeyFloat",     c.none,   bg_float)

    -- ── Plugin: indent-blankline ────────────────────────────────────────
    hi("IblIndent", c.bg2, c.none)
    hi("IblScope",  c.bg3, c.none)

    -- ── Plugin: nvim-cmp ────────────────────────────────────────────────
    link("CmpItemAbbr",         "Pmenu")
    hi("CmpItemAbbrMatch",      c.yellow, c.none, "bold")
    hi("CmpItemAbbrMatchFuzzy", c.yellow, c.none)
    link("CmpItemMenu",         "Comment")
    hi("CmpItemKindFunction",   c.blue,   c.none)
    hi("CmpItemKindMethod",     c.blue,   c.none)
    hi("CmpItemKindVariable",   c.fg1,    c.none)
    hi("CmpItemKindKeyword",    c.yellow, c.none)
    hi("CmpItemKindText",       c.fg,     c.none)
    hi("CmpItemKindModule",     c.steel,  c.none)
end

return M

