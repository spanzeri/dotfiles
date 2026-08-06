-- lua/vs-dark.lua
-- VS Dark — Neovim theme inspired by Visual Studio 2026's Dark theme
-- Fluent-era chrome greys + the classic Visual Studio editor classification
-- colours (blue keywords, purple control flow, salmon strings, green comments).

local M = {}

M.config = {
    transparent = false,
    italic = true,
}

function M.setup(opts)
    M.config = vim.tbl_deep_extend("force", M.config, opts or {})
end

function M.load()
    vim.cmd("hi clear")
    if vim.fn.exists("syntax_on") == 1 then vim.cmd("syntax reset") end
    vim.g.colors_name = "vs-dark"
    vim.o.background = "dark"

    local transparent = M.config.transparent
    local c = {
        -- Surfaces (Visual Studio 2026 Fluent dark chrome)
        bg        = "#1f1f1f", -- editor
        bg_dim    = "#181818", -- deepest chrome (tab strip, inactive)
        bg1       = "#252526", -- cursorline / subtle surface
        bg2       = "#2d2d30", -- panels, statusline, tabline
        bg3       = "#3a3a3c", -- floats, popup menu, borders
        bg4       = "#4a4a4e", -- brighter border / scrollbar thumb

        -- Text
        fg        = "#d9d9d9", -- plain text
        fg1       = "#f1f1f1", -- emphasised text
        fg_dim    = "#9b9b9b", -- preprocessor, muted UI text
        gray      = "#6a6a6a", -- comments-adjacent chrome, whitespace

        -- Selection / accents
        sel       = "#264f78", -- editor selection
        sel_dim   = "#3a3d41", -- inactive selection
        find      = "#515c6a", -- find match
        accent    = "#0078d4", -- VS accent blue
        accent_lt = "#4cc2ff", -- VS light accent

        -- Editor classifications
        blue      = "#5c9bc9", -- keywords, builtin types, tags
        purple    = "#d7a0de", -- control-flow keywords
        salmon    = "#d69d85", -- strings
        green     = "#58a64a", -- comments
        green_doc = "#608b4e", -- doc comments
        num       = "#b5cea8", -- numbers
        teal      = "#4cbbb1", -- classes, types, namespaces
        lgreen    = "#b8d7a3", -- interfaces, enums, constants
        sgreen    = "#86c691", -- structs
        yellow    = "#dcdcaa", -- methods
        sky       = "#9cdcfe", -- parameters, xml attributes
        gold      = "#d7ba7d", -- escapes, regex bits, current search
        mauve     = "#beb7ff", -- macros
        op        = "#b4b4b4", -- operators
        lnum      = "#8a8a8a", -- line numbers
        lnum_cur  = "#2b91af", -- current line number

        -- Diagnostics / VCS
        red       = "#f44747",
        amber     = "#cca700",
        info      = "#4fc1ff",
        dim_red   = "#d16969",

        diff_add  = "#20301f",
        diff_del  = "#3a2323",
        diff_chg  = "#1f2c3d",
        diff_txt  = "#2d4a6b",

        white     = "#ffffff",
        none      = "NONE",
    }

    -- When transparent, remove backgrounds from the groups that sit directly
    -- on the terminal canvas so the terminal background shows through.
    local bg        = transparent and c.none or c.bg
    local bg_float  = transparent and c.none or c.bg2
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

    local function italic()
        return M.config.italic and "italic" or nil
    end

    -- ── Editor ──────────────────────────────────────────────────────────
    hi("Normal",        c.fg,       bg)
    hi("NormalFloat",   c.fg,       bg_float)
    hi("FloatBorder",   c.bg4,      bg_float)
    hi("FloatTitle",    c.fg1,      bg_float, "bold")
    hi("Cursor",        c.bg,       c.fg1)
    hi("CursorLine",    c.none,     c.bg1,    "none")
    hi("CursorColumn",  c.none,     c.bg1)
    hi("CursorLineNr",  c.lnum_cur, c.none,   "bold")
    hi("LineNr",        c.lnum,     c.none)
    hi("LineNrAbove",   c.lnum,     c.none)
    hi("LineNrBelow",   c.lnum,     c.none)
    hi("SignColumn",    c.bg4,      bg_sign)
    hi("ColorColumn",   c.none,     c.bg1)
    hi("VertSplit",     c.bg3,      bg)
    hi("WinSeparator",  c.bg3,      bg)
    hi("Folded",        c.fg_dim,   c.bg2,    italic())
    hi("FoldColumn",    c.bg4,      bg_sign)
    hi("EndOfBuffer",   c.bg2,      c.none)
    hi("NonText",       c.gray,     c.none)
    hi("SpecialKey",    c.gray,     c.none)
    hi("Conceal",       c.gray,     c.none)
    hi("Whitespace",    c.bg3,      c.none)
    hi("NormalNC",      c.fg,       c.none)
    hi("NormalFloatNC", c.fg,       bg)
    hi("QuickFixLine",  c.none,     c.sel_dim)
    hi("Winbar",        c.fg_dim,   c.none)
    hi("WinbarNC",      c.gray,     c.none)

    -- ── Selection / Search ──────────────────────────────────────────────
    hi("Visual",        c.none,   c.sel)
    hi("VisualNOS",     c.none,   c.sel_dim)
    hi("Search",        c.fg1,    c.find)
    hi("IncSearch",     c.bg,     c.gold)
    hi("CurSearch",     c.bg,     c.gold)
    hi("Substitute",    c.bg,     c.dim_red)

    -- ── UI chrome ───────────────────────────────────────────────────────
    hi("StatusLine",    c.fg,      c.bg2)
    hi("StatusLineNC",  c.fg_dim,  c.bg1)
    hi("TabLine",       c.fg_dim,  c.bg_dim, "none")
    hi("TabLineFill",   c.none,    c.bg_dim, "none")
    hi("TabLineSel",    c.fg1,     c.bg,     "bold")
    hi("Pmenu",         c.fg,      c.bg3)
    hi("PmenuSel",      c.fg1,     c.sel,    "bold")
    hi("PmenuKind",     c.teal,    c.bg3)
    hi("PmenuKindSel",  c.teal,    c.sel)
    hi("PmenuExtra",    c.fg_dim,  c.bg3)
    hi("PmenuExtraSel", c.fg_dim,  c.sel)
    hi("PmenuSbar",     c.none,    c.bg2)
    hi("PmenuThumb",    c.none,    c.bg4)
    hi("WildMenu",      c.fg1,     c.sel)
    hi("ModeMsg",       c.fg1,     c.none, "bold")
    hi("MsgArea",       c.fg,      c.none)
    hi("MsgSeparator",  c.bg4,     c.bg2)

    -- ── Diagnostics ─────────────────────────────────────────────────────
    hi("DiagnosticError",            c.red,   c.none)
    hi("DiagnosticWarn",             c.amber, c.none)
    hi("DiagnosticInfo",             c.info,  c.none)
    hi("DiagnosticHint",             c.sky,   c.none)
    hi("DiagnosticOk",               c.green, c.none)
    hi("DiagnosticUnderlineError",   c.none,  c.none, "undercurl")
    hi("DiagnosticUnderlineWarn",    c.none,  c.none, "undercurl")
    hi("DiagnosticUnderlineInfo",    c.none,  c.none, "undercurl")
    hi("DiagnosticUnderlineHint",    c.none,  c.none, "undercurl")
    hi("DiagnosticVirtualTextError", c.red,   c.none, italic())
    hi("DiagnosticVirtualTextWarn",  c.amber, c.none, italic())
    hi("DiagnosticVirtualTextInfo",  c.info,  c.none, italic())
    hi("DiagnosticVirtualTextHint",  c.sky,   c.none, italic())
    hi("DiagnosticUnnecessary",      c.gray,  c.none)
    hi("DiagnosticDeprecated",       c.gray,  c.none, "strikethrough")

    -- ── LSP ─────────────────────────────────────────────────────────────
    hi("LspReferenceText",  c.none, c.sel_dim)
    hi("LspReferenceRead",  c.none, c.sel_dim)
    hi("LspReferenceWrite", c.none, c.sel_dim)
    hi("LspInlayHint",      c.gray, c.bg1, italic())
    hi("LspSignatureActiveParameter", c.fg1, c.sel, "bold")
    hi("LspCodeLens",       c.gray, c.none, italic())

    -- ── Misc UI ─────────────────────────────────────────────────────────
    hi("Question",   c.lgreen, c.none, "bold")
    hi("MoreMsg",    c.lgreen, c.none, "bold")
    hi("ErrorMsg",   c.red,    c.none, "bold")
    hi("WarningMsg", c.amber,  c.none, "bold")
    hi("Directory",  c.blue,   c.none, "bold")
    hi("Title",      c.accent_lt, c.none, "bold")
    hi("MatchParen", c.fg1,    "#3a5379", "bold")
    hi("SpellBad",   c.none,   c.none, "undercurl")
    hi("SpellCap",   c.none,   c.none, "undercurl")
    hi("SpellRare",  c.none,   c.none, "undercurl")
    hi("SpellLocal", c.none,   c.none, "undercurl")

    -- ── Diff ────────────────────────────────────────────────────────────
    hi("DiffAdd",    c.none,   c.diff_add)
    hi("DiffChange", c.none,   c.diff_chg)
    hi("DiffDelete", c.dim_red, c.diff_del)
    hi("DiffText",   c.none,   c.diff_txt, "bold")
    hi("Added",      c.green,  c.none)
    hi("Changed",    c.blue,   c.none)
    hi("Removed",    c.dim_red, c.none)

    -- ── Syntax (classic vim) ────────────────────────────────────────────
    hi("Comment",       c.green,   c.none, italic())
    hi("String",        c.salmon,  c.none)
    hi("Character",     c.salmon,  c.none)
    hi("Number",        c.num,     c.none)
    hi("Boolean",       c.blue,    c.none)
    hi("Float",         c.num,     c.none)
    hi("Constant",      c.lgreen,  c.none)
    hi("Identifier",    c.fg,      c.none)
    hi("Function",      c.yellow,  c.none)
    hi("Keyword",       c.blue,    c.none)
    hi("Statement",     c.blue,    c.none)
    hi("Conditional",   c.purple,  c.none)
    hi("Repeat",        c.purple,  c.none)
    hi("Label",         c.purple,  c.none)
    hi("Operator",      c.op,      c.none)
    hi("Exception",     c.purple,  c.none)
    hi("PreProc",       c.fg_dim,  c.none)
    hi("Include",       c.fg_dim,  c.none)
    hi("Define",        c.fg_dim,  c.none)
    hi("Macro",         c.mauve,   c.none)
    hi("PreCondit",     c.fg_dim,  c.none)
    hi("Type",          c.teal,    c.none)
    hi("StorageClass",  c.blue,    c.none)
    hi("Structure",     c.sgreen,  c.none)
    hi("Typedef",       c.teal,    c.none)
    hi("Special",       c.gold,    c.none)
    hi("SpecialChar",   c.gold,    c.none)
    hi("SpecialComment",c.green_doc, c.none, italic())
    hi("Tag",           c.blue,    c.none)
    hi("Delimiter",     c.fg,      c.none)
    hi("Debug",         c.mauve,   c.none)
    hi("Underlined",    c.accent_lt, c.none, "underline")
    hi("Error",         c.red,     c.none, "bold")
    hi("Todo",          c.bg,      c.gold, "bold")

    -- ── Treesitter ──────────────────────────────────────────────────────
    link("@variable",              "Identifier")
    hi("@variable.builtin",        c.blue,   c.none)
    hi("@variable.parameter",      c.sky,    c.none)
    hi("@variable.member",         c.fg,     c.none)
    link("@constant",              "Constant")
    hi("@constant.builtin",        c.blue,   c.none)
    link("@constant.macro",        "Macro")
    hi("@module",                  c.teal,   c.none)
    link("@module.builtin",        "@module")
    link("@label",                 "Label")

    link("@string",                "String")
    link("@string.escape",         "SpecialChar")
    link("@string.special",        "SpecialChar")
    hi("@string.regexp",           c.dim_red, c.none)
    link("@character",             "Character")
    link("@character.special",     "SpecialChar")
    link("@number",                "Number")
    link("@number.float",          "Float")
    link("@boolean",               "Boolean")

    link("@type",                  "Type")
    hi("@type.builtin",            c.blue,   c.none)
    link("@type.definition",       "Typedef")
    hi("@type.qualifier",          c.blue,   c.none)
    hi("@attribute",               c.teal,   c.none)
    link("@attribute.builtin",     "@attribute")
    hi("@property",                c.fg,     c.none)
    hi("@field",                   c.fg,     c.none)

    link("@function",              "Function")
    link("@function.builtin",      "Function")
    link("@function.macro",        "Macro")
    link("@function.method",       "Function")
    link("@function.method.call",  "Function")
    link("@function.call",         "Function")
    hi("@constructor",             c.teal,   c.none)

    link("@keyword",               "Keyword")
    hi("@keyword.function",        c.blue,   c.none)
    hi("@keyword.operator",        c.blue,   c.none)
    link("@keyword.import",        "Keyword")
    hi("@keyword.storage",         c.blue,   c.none)
    hi("@keyword.modifier",        c.blue,   c.none)
    hi("@keyword.type",            c.blue,   c.none)
    hi("@keyword.coroutine",       c.purple, c.none)
    hi("@keyword.return",          c.purple, c.none)
    link("@keyword.exception",     "Exception")
    link("@keyword.conditional",   "Conditional")
    link("@keyword.repeat",        "Repeat")
    link("@keyword.debug",         "Debug")
    hi("@keyword.directive",       c.fg_dim, c.none)
    hi("@keyword.directive.define", c.fg_dim, c.none)

    link("@operator",              "Operator")
    link("@punctuation.delimiter", "Delimiter")
    link("@punctuation.bracket",   "Delimiter")
    hi("@punctuation.special",     c.gold,   c.none)

    link("@comment",               "Comment")
    hi("@comment.documentation",   c.green_doc, c.none, italic())
    link("@comment.todo",          "Todo")
    hi("@comment.error",           c.bg,     c.red,   "bold")
    hi("@comment.warning",         c.bg,     c.amber, "bold")
    hi("@comment.note",            c.bg,     c.info,  "bold")

    hi("@markup.heading",          c.accent_lt, c.none, "bold")
    hi("@markup.strong",           c.fg1,    c.none, "bold")
    hi("@markup.italic",           c.fg1,    c.none, italic())
    hi("@markup.strikethrough",    c.gray,   c.none, "strikethrough")
    hi("@markup.quote",            c.fg_dim, c.none, italic())
    link("@markup.raw",            "String")
    link("@markup.link",           "Underlined")
    hi("@markup.link.label",       c.sky,    c.none)
    hi("@markup.link.url",         c.accent_lt, c.none, "underline")
    hi("@markup.list",             c.blue,   c.none)
    hi("@markup.list.checked",     c.green,  c.none)
    hi("@markup.list.unchecked",   c.fg_dim, c.none)

    hi("@diff.plus",               c.green,  c.none)
    hi("@diff.minus",              c.dim_red, c.none)
    hi("@diff.delta",              c.blue,   c.none)

    link("@tag",                   "Tag")
    hi("@tag.builtin",             c.blue,   c.none)
    hi("@tag.attribute",           c.sky,    c.none)
    hi("@tag.delimiter",           c.fg_dim, c.none)

    -- ── LSP semantic tokens ─────────────────────────────────────────────
    link("@lsp.type.variable",      "@variable")
    link("@lsp.type.parameter",     "@variable.parameter")
    link("@lsp.type.property",      "@variable.member")
    link("@lsp.type.function",      "@function")
    link("@lsp.type.method",        "@function.method")
    link("@lsp.type.macro",         "@function.macro")
    link("@lsp.type.keyword",       "@keyword")
    link("@lsp.type.type",          "@type")
    hi("@lsp.type.class",           c.teal,   c.none)
    hi("@lsp.type.interface",       c.lgreen, c.none)
    hi("@lsp.type.enum",            c.lgreen, c.none)
    hi("@lsp.type.enumMember",      c.lgreen, c.none)
    hi("@lsp.type.struct",          c.sgreen, c.none)
    hi("@lsp.type.typeParameter",   c.lgreen, c.none)
    link("@lsp.type.namespace",     "@module")
    link("@lsp.type.string",        "@string")
    link("@lsp.type.number",        "@number")
    link("@lsp.type.boolean",       "@boolean")
    link("@lsp.type.comment",       "@comment")
    link("@lsp.type.decorator",     "@attribute")
    link("@lsp.type.operator",      "@operator")
    link("@lsp.type.modifier",      "@keyword.modifier")
    link("@lsp.type.event",         "@variable.member")
    link("@lsp.mod.deprecated",     "DiagnosticDeprecated")
    link("@lsp.mod.readonly",       "@constant")
    link("@lsp.typemod.method.readonly",   "@function.method")
    link("@lsp.typemod.variable.readonly", "@constant")
    link("@lsp.typemod.function.declaration", "@function")

    -- ── Plugin: gitsigns ────────────────────────────────────────────────
    hi("GitSignsAdd",    c.green,   c.none)
    hi("GitSignsChange", c.blue,    c.none)
    hi("GitSignsDelete", c.dim_red, c.none)
    hi("GitSignsCurrentLineBlame", c.gray, c.none, italic())

    -- ── Plugin: nvim-tree / neo-tree ────────────────────────────────────
    link("NvimTreeNormal",         "Normal")
    hi("NvimTreeRootFolder",       c.teal,    c.none, "bold")
    hi("NvimTreeFolderName",       c.blue,    c.none)
    hi("NvimTreeOpenedFolderName", c.blue,    c.none, "bold")
    hi("NvimTreeGitDirty",         c.amber,   c.none)
    hi("NvimTreeGitNew",           c.green,   c.none)
    hi("NvimTreeGitDeleted",       c.dim_red, c.none)

    -- ── Plugin: Telescope ───────────────────────────────────────────────
    hi("TelescopeNormal",         c.fg,     bg)
    hi("TelescopeBorder",         c.bg4,    bg)
    hi("TelescopePromptBorder",   c.accent, bg)
    hi("TelescopeResultsBorder",  c.bg4,    bg)
    hi("TelescopePreviewBorder",  c.bg4,    bg)
    hi("TelescopeSelectionCaret", c.accent_lt, c.none)
    hi("TelescopeSelection",      c.fg1,    c.sel)
    hi("TelescopeMatching",       c.gold,   c.none, "bold")

    -- ── Plugin: Snacks ──────────────────────────────────────────────────
    -- Pane backgrounds
    hi("SnacksPickerList",           c.fg,     bg)
    hi("SnacksPickerInput",          c.fg,     bg)
    hi("SnacksPickerPreview",        c.fg,     bg)
    -- Borders
    hi("SnacksPickerListBorder",     c.bg4,    bg)
    hi("SnacksPickerInputBorder",    c.accent, bg)
    hi("SnacksPickerPreviewBorder",  c.bg4,    bg)
    -- Titles
    hi("SnacksPickerListTitle",      c.fg1,    c.accent)
    hi("SnacksPickerInputTitle",     c.fg1,    c.accent)
    hi("SnacksPickerPreviewTitle",   c.fg,     c.bg3)
    -- Prompt / query
    hi("SnacksPickerPrompt",         c.accent_lt, c.none)
    -- Results list
    hi("SnacksPickerMatch",          c.gold,   c.none, "bold")
    hi("SnacksPickerCursorLine",     c.none,   c.sel,  "none")
    -- File / dir entries
    hi("SnacksPickerFile",           c.fg,     c.none)
    hi("SnacksPickerDir",            c.fg_dim, c.none)
    hi("SnacksPickerDirCursorLine",  c.fg,     c.none)
    hi("SnacksPickerPathHidden",     c.gray,   c.none)
    -- Line / col numbers shown in results
    hi("SnacksPickerRow",            c.lnum,   c.none)
    hi("SnacksPickerCol",            c.lnum,   c.none)
    -- Git status letters
    hi("SnacksPickerGitStatusAdded",     c.green,   c.none)
    hi("SnacksPickerGitStatusModified",  c.blue,    c.none)
    hi("SnacksPickerGitStatusDeleted",   c.dim_red, c.none)
    hi("SnacksPickerGitStatusRenamed",   c.teal,    c.none)
    hi("SnacksPickerGitStatusUntracked", c.fg_dim,  c.none)
    -- Footer / keymap hints
    hi("SnacksPickerFooter",         c.bg4,    bg)
    hi("SnacksPickerToggle",         c.gold,   c.none, "bold")
    hi("SnacksPickerKeymapDesc",     c.fg,     c.none)
    hi("SnacksPickerKeymapSep",      c.gray,   c.none)
    -- Notifier / dashboard
    hi("SnacksNotifierInfo",         c.info,   c.none)
    hi("SnacksNotifierWarn",         c.amber,  c.none)
    hi("SnacksNotifierError",        c.red,    c.none)
    hi("SnacksDashboardHeader",      c.accent_lt, c.none, "bold")
    hi("SnacksDashboardDesc",        c.fg,     c.none)
    hi("SnacksDashboardKey",         c.gold,   c.none)
    hi("SnacksDashboardIcon",        c.teal,   c.none)

    -- ── Plugin: which-key ───────────────────────────────────────────────
    hi("WhichKey",          c.gold,   c.none)
    hi("WhichKeyGroup",     c.blue,   c.none)
    hi("WhichKeyDesc",      c.fg,     c.none)
    hi("WhichKeySeparator", c.gray,   c.none)
    hi("WhichKeyFloat",     c.none,   bg_float)
    hi("WhichKeyTitle",     c.fg1,    c.accent, "bold")
    hi("WhichKeyBorder",    c.bg4,    bg_float)

    -- ── Plugin: indent-blankline ────────────────────────────────────────
    hi("IblIndent", c.bg2, c.none)
    hi("IblScope",  c.bg4, c.none)

    -- ── Plugin: blink.cmp ───────────────────────────────────────────────
    hi("BlinkCmpMenu",              c.fg,     c.bg3)
    hi("BlinkCmpMenuBorder",        c.bg4,    c.bg3)
    hi("BlinkCmpMenuSelection",     c.fg1,    c.sel,  "bold")
    hi("BlinkCmpScrollBarThumb",    c.none,   c.bg4)
    hi("BlinkCmpScrollBarGutter",   c.none,   c.bg2)
    hi("BlinkCmpLabel",             c.fg,     c.none)
    hi("BlinkCmpLabelMatch",        c.gold,   c.none, "bold")
    hi("BlinkCmpLabelDeprecated",   c.gray,   c.none, "strikethrough")
    hi("BlinkCmpLabelDetail",       c.fg_dim, c.none)
    hi("BlinkCmpLabelDescription",  c.fg_dim, c.none)
    hi("BlinkCmpKind",              c.teal,   c.none)
    hi("BlinkCmpSource",            c.gray,   c.none)
    hi("BlinkCmpDoc",               c.fg,     c.bg3)
    hi("BlinkCmpDocBorder",         c.bg4,    c.bg3)
    hi("BlinkCmpDocSeparator",      c.bg4,    c.bg3)
    hi("BlinkCmpSignatureHelp",     c.fg,     c.bg3)
    hi("BlinkCmpSignatureHelpBorder", c.bg4,  c.bg3)
    hi("BlinkCmpSignatureHelpActiveParameter", c.fg1, c.sel, "bold")
    hi("BlinkCmpGhostText",         c.gray,   c.none, italic())
    -- Kind icons follow the editor classifications
    hi("BlinkCmpKindFunction",      c.yellow, c.none)
    hi("BlinkCmpKindMethod",        c.yellow, c.none)
    hi("BlinkCmpKindConstructor",   c.yellow, c.none)
    hi("BlinkCmpKindClass",         c.teal,   c.none)
    hi("BlinkCmpKindStruct",        c.sgreen, c.none)
    hi("BlinkCmpKindInterface",     c.lgreen, c.none)
    hi("BlinkCmpKindEnum",          c.lgreen, c.none)
    hi("BlinkCmpKindEnumMember",    c.lgreen, c.none)
    hi("BlinkCmpKindVariable",      c.sky,    c.none)
    hi("BlinkCmpKindField",         c.sky,    c.none)
    hi("BlinkCmpKindProperty",      c.sky,    c.none)
    hi("BlinkCmpKindKeyword",       c.blue,   c.none)
    hi("BlinkCmpKindSnippet",       c.mauve,  c.none)
    hi("BlinkCmpKindText",          c.fg,     c.none)
    hi("BlinkCmpKindModule",        c.teal,   c.none)
    hi("BlinkCmpKindFile",          c.fg,     c.none)
    hi("BlinkCmpKindFolder",        c.blue,   c.none)

    -- ── Plugin: nvim-cmp (kept for parity) ──────────────────────────────
    link("CmpItemAbbr",         "Pmenu")
    hi("CmpItemAbbrMatch",      c.gold,   c.none, "bold")
    hi("CmpItemAbbrMatchFuzzy", c.gold,   c.none)
    link("CmpItemMenu",         "Comment")
    hi("CmpItemKindFunction",   c.yellow, c.none)
    hi("CmpItemKindMethod",     c.yellow, c.none)
    hi("CmpItemKindVariable",   c.sky,    c.none)
    hi("CmpItemKindKeyword",    c.blue,   c.none)
    hi("CmpItemKindText",       c.fg,     c.none)
    hi("CmpItemKindModule",     c.teal,   c.none)

    -- ── Plugin: mini.statusline ─────────────────────────────────────────
    hi("MiniStatuslineModeNormal",  c.white, c.accent,  "bold")
    hi("MiniStatuslineModeInsert",  c.bg,    c.green,   "bold")
    hi("MiniStatuslineModeVisual",  c.bg,    c.purple,  "bold")
    hi("MiniStatuslineModeReplace", c.bg,    c.dim_red, "bold")
    hi("MiniStatuslineModeCommand", c.bg,    c.gold,    "bold")
    hi("MiniStatuslineModeOther",   c.bg,    c.teal,    "bold")
    hi("MiniStatuslineDevinfo",     c.fg_dim, c.bg2)
    hi("MiniStatuslineFilename",    c.fg,     c.bg1)
    hi("MiniStatuslineFileinfo",    c.fg_dim, c.bg2)
    hi("MiniStatuslineInactive",    c.gray,   c.bg1)

    -- ── Plugin: nvim-dap / dap-ui ───────────────────────────────────────
    hi("DapBreakpoint",          c.red,     c.none)
    hi("DapBreakpointCondition", c.amber,   c.none)
    hi("DapBreakpointRejected",  c.gray,    c.none)
    hi("DapLogPoint",            c.info,    c.none)
    hi("DapStopped",             c.gold,    c.none)
    hi("DapStoppedLine",         c.none,    "#3a3a1f")
    hi("NvimDapVirtualText",     c.teal,    c.none, italic())
    hi("NvimDapVirtualTextChanged", c.gold, c.none, italic())

    hi("DapUINormal",            c.fg,      c.none)
    hi("DapUIVariable",          c.sky,     c.none)
    hi("DapUIScope",             c.accent_lt, c.none)
    hi("DapUIType",              c.teal,    c.none)
    hi("DapUIValue",             c.fg,      c.none)
    hi("DapUIModifiedValue",     c.gold,    c.none, "bold")
    hi("DapUIDecoration",        c.accent_lt, c.none)
    hi("DapUIThread",            c.green,   c.none)
    hi("DapUIStoppedThread",     c.accent_lt, c.none)
    hi("DapUIFrameName",         c.fg,      c.none)
    hi("DapUISource",            c.mauve,   c.none)
    hi("DapUILineNumber",        c.lnum_cur, c.none)
    hi("DapUIFloatBorder",       c.bg4,     c.none)
    hi("DapUIWatchesEmpty",      c.dim_red, c.none)
    hi("DapUIWatchesValue",      c.green,   c.none)
    hi("DapUIWatchesError",      c.red,     c.none)
    hi("DapUIBreakpointsPath",   c.accent_lt, c.none)
    hi("DapUIBreakpointsInfo",   c.green,   c.none)
    hi("DapUIBreakpointsCurrentLine", c.green, c.none, "bold")
    hi("DapUIBreakpointsLine",   c.lnum_cur, c.none)
    hi("DapUIBreakpointsDisabledLine", c.gray, c.none)
    hi("DapUICurrentFrameName",  c.green,   c.none, "bold")
    hi("DapUIPlayPause",         c.green,   c.none)
    hi("DapUIRestart",           c.green,   c.none)
    hi("DapUIStop",              c.dim_red, c.none)
    hi("DapUIUnavailable",       c.gray,    c.none)
    hi("DapUIStepOver",          c.accent_lt, c.none)
    hi("DapUIStepInto",          c.accent_lt, c.none)
    hi("DapUIStepBack",          c.accent_lt, c.none)
    hi("DapUIStepOut",           c.accent_lt, c.none)
    hi("DapUIWinSelect",         c.gold,    c.none, "bold")

    -- ── Plugin: minuet ──────────────────────────────────────────────────
    link("MinuetVirtualText", "NonText")

    -- ── Terminal ────────────────────────────────────────────────────────
    vim.g.terminal_color_0  = c.bg
    vim.g.terminal_color_1  = c.dim_red
    vim.g.terminal_color_2  = c.green
    vim.g.terminal_color_3  = c.gold
    vim.g.terminal_color_4  = c.blue
    vim.g.terminal_color_5  = c.purple
    vim.g.terminal_color_6  = c.teal
    vim.g.terminal_color_7  = c.fg
    vim.g.terminal_color_8  = c.gray
    vim.g.terminal_color_9  = c.red
    vim.g.terminal_color_10 = c.num
    vim.g.terminal_color_11 = c.yellow
    vim.g.terminal_color_12 = c.sky
    vim.g.terminal_color_13 = c.mauve
    vim.g.terminal_color_14 = c.accent_lt
    vim.g.terminal_color_15 = c.fg1
end

return M
