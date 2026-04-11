-- =============================================================================
-- Plugins
-- =============================================================================

local command_group = vim.api.nvim_create_augroup('SamConfig-Plugins', { clear = true })

local function plugin_hook(ev)
    local name, kind = ev.data.spec.name, ev.data.kind
    local update_infos = {
        { name = 'nvim-treesitter', command = 'TSUpdate' },
        {
            name = 'avante',
            syscommand = function()
                return vim.fn.has('win32') == 0
                    and { 'powershell', '-ExecutionPolicy', 'Bypass', '-File', 'Build.ps1', '-BuildFromSource', 'false'}
                    or { 'make' }
            end
        },
        { name = 'blink.cmp', syscommand = { 'cargo', 'build', '--release' } },
    }
    local function get_cmd(cmd)
        if cmd == nil then
            return nil
        end
        if type(cmd) == 'function' then
            return cmd()
        end
        return cmd
    end

    vim.notify('Plugin: '..name..' is running: '..kind, vim.log.levels.WARN)

    if kind == 'update' or kind == 'install' then
        for _, info in ipairs(update_infos) do
            if name == info.name then
                -- System command
                local cmd = get_cmd(info.syscommand)
                vim.notify('Cmd: '..vim.inspect(cmd), vim.log.levels.WARN)
                if cmd ~= nil then
                    vim.system(cmd, { cwd = ev.data.path })
                end
                -- Built-in command
                cmd = get_cmd(info.command)
                if cmd ~= nil then
                    if not ev.data.active then vim.cmd.packadd(info.name) end
                    vim.cmd(cmd)
                end
            end
        end
    end
end

vim.api.nvim_create_autocmd('PackChanged', {
    group    = command_group,
    callback = plugin_hook,
})

vim.pack.add({
    'https://github.com/nvim-lua/plenary.nvim',
    'https://github.com/nvim-mini/mini.nvim',
    'https://github.com/ibhagwan/fzf-lua',
    'https://github.com/stevearc/oil.nvim',
    'https://github.com/nvim-treesitter/nvim-treesitter',
    'https://github.com/nvim-treesitter/nvim-treesitter-textobjects',
    'https://github.com/sar/friendly-snippets.nvim',
    'https://github.com/Saghen/blink.cmp',
    'https://github.com/neovim/nvim-lspconfig',
    'https://github.com/williamboman/mason.nvim',
    'https://github.com/aserowy/tmux.nvim',
    'https://github.com/nvim-neotest/nvim-nio',
    'https://github.com/rcarriga/nvim-dap-ui',
    'https://github.com/theHamsta/nvim-dap-virtual-text',
    'https://github.com/mfussenegger/nvim-dap',
    'https://github.com/MeanderingProgrammer/render-markdown.nvim',
    'https://github.com/MunifTanjim/nui.nvim',
    'https://github.com/yetone/avante.nvim',
    'https://github.com/lewis6991/gitsigns.nvim',
    'https://github.com/esmuellert/codediff.nvim',
})

-- Load built-in and personal plugins

vim.cmd.packadd('nvim.undotree')
vim.cmd.packadd('nvim.difftool')
vim.cmd.packadd('nohlsearch')
vim.cmd.packadd('hl-comments')

-- Mini (collection of plugins)

require('mini.ai').setup({ n_lines = 500 })
require('mini.surround').setup()
require('mini.splitjoin').setup()
require('mini.icons').setup()
require('mini.align').setup()

local mini_statusline = require('mini.statusline')
mini_statusline.setup({ use_icons = true })
mini_statusline.section_location = function() return '%2l:%-2v' end

local mini_trailspace = require('mini.trailspace')
mini_trailspace.setup()
vim.api.nvim_create_user_command('TrimWhitespaces', mini_trailspace.trim, {})

require('mini.bufremove').setup()
vim.keymap.set('n', '<leader>bd', MiniBufremove.delete, { desc = '[b]uffer [d]elete' })

-- FZF (fuzzy finder)

local fzf = require('fzf-lua')
fzf.setup({
    ui_select = true,
    keymap = {
        builtin = {
            ['<C-d>'] = 'preview-page-down',
            ['<C-u>'] = 'preview-page-up',
        },
    },
})

-- Query for a custom location or try to infer it from the previuos
-- value or the current buffer path. Supports OIL paths as well.
local function get_default_search_location(location)
    if location ~= nil and #location > 0 then
        return location
    end
    local curr_loc = vim.fn.expand('%:p:h')
    if curr_loc == nil or #curr_loc == 0 then
        curr_loc = vin.fn.get_cwd()
    end
    local oil_prefix = 'oil://'
    if curr_loc:sub(1, #oil_prefix) == oil_prefix then
        curr_loc = curr_loc:sub(#oil_prefix + 1)
    end
    return curr_loc
end

local function get_custom_search_location(opts)
    local opts = vim.tbl_deep_extend(
        'force',
        {
            prompt       = '> Where: ',
            default      = nil,
            error        = 'Location not found',
            autocomplete = 'dir',
        }, opts or {})

    local loc = vim.fn.input(opts.prompt, get_default_search_location(opts.default), opts.autocomplete)

    if loc == nil or #loc == 0 then
        vim.notify(opts.error, vim.log.levels.ERROR)
        return nil
    end
    if vim.fn.isdirectory(loc) == 0 then
        vim.notify('Directory does not exist: ' .. loc, vim.log.levels.ERROR)
        return nil
    end

    return loc
end

local other_file_dir
local function search_other_dir()
    other_search_dir = get_custom_search_location({ default = other_search_dir })
    if other_search_dir ~= nil then
        fzf.files({ cwd = other_search_dir })
    end
end

local other_grep_dir
local function grep_other_dir()
    other_grep_dir = get_custom_search_location({ default = other_grep_dir, prompt = '> Grep location:' })
    if other_grep_dir ~= nil then
        fzf.live_grep({ cwd = other_search_dir })
    end
end

local function search_config()
    fzf.files({ cwd = vim.fn.stdpath('config') })
end

vim.keymap.set('n', '<leader>sf',       fzf.files,        { desc = '[s]earch [f]ile' })
vim.keymap.set('n', '<leader>sb',       fzf.buffers,      { desc = '[s]earch [b]uffers' })
vim.keymap.set('n', '<leader>sh',       fzf.helptags,     { desc = '[s]earch [h]elp' })
vim.keymap.set('n', '<leader>sm',       fzf.marks,        { desc = '[s]earch [m]arks' })
vim.keymap.set('n', '<leader>sM',       fzf.manpages,     { desc = '[s]earch [M]anpages' })
vim.keymap.set('n', '<leader>sr',       fzf.registers,    { desc = '[s]earch [r]egisters' })
vim.keymap.set('n', '<leader>sw',       fzf.grep_cWORD,   { desc = '[s]earch [w]ord under cursor' })
vim.keymap.set('n', '<leader>sn',       search_config,    { desc = '[s]earch [n]eovim config' })
vim.keymap.set('n', '<leader>so',       search_other_dir, { desc = '[s]earch [o]ther directory' })
vim.keymap.set('n', '<leader>sg',       fzf.live_grep,    { desc = '[s]earch [g]rep' })
vim.keymap.set('n', '<leader>sG',       grep_other_dir,   { desc = '[s]earch [G]rep other directory' })
vim.keymap.set('n', '<leader>sc',       fzf.resume,       { desc = '[s]earch [c]ontinue last' })
vim.keymap.set('n', '<leader>sx',       fzf.builtin,      { desc = '[s]earch [x]: all available pickers' })
vim.keymap.set('n', '<leader><leader>', fzf.global,       { desc = 'Global search' })

-- OIL (manage files and directories like a text buffer)

require('oil').setup({
    columns = { 'icon', 'permissions', 'size', 'mtime' },
    keymaps = {
        ['<C-h>'] = false,
    ['<M-h>'] = 'actions.select_split',
    ['<BS>']  = 'actions.parent',
    },
    view_options = { show_hidden = true },
    watch_for_changes = true,
})

vim.keymap.set('n', '-', '<CMD>Oil<CR>', { desc = 'Open file browser' })

-- Treesitter (parser)

vim.api.nvim_create_autocmd('FileType', {
    callback = function()
        -- Enable treesitter highlighting
        pcall(vim.treesitter.start)
        -- Enable treesitter indentation
        vim.bo.indentexpr = 'v:lua.require(\'nvim-treesitter\').indentexpr()'
    end,
    group = command_group,
})

local ts_ensure_installed   = { 'c', 'lua', 'luadoc', 'cpp', 'glsl', 'hlsl' }
local ts_already_installed  = require('nvim-treesitter.config').get_installed()
local ts_parsers_to_install = vim.iter(ts_ensure_installed)
    :filter(function(parser) return not vim.tbl_contains(ts_already_installed, partser) end)
    :totable()
require('nvim-treesitter').install(ts_parsers_to_install)

require('nvim-treesitter-textobjects').setup({})

local function ts_move_start_keymap(key, where, desc)
    local ts_move = require('nvim-treesitter-textobjects.move')
    vim.keymap.set({ 'n', 'x', 'o' }, key, function() ts_move.goto_next_start(where, 'textobjects') end, { desc = desc })
end

local function ts_move_end_keymap(key, where, desc)
    local ts_move = require('nvim-treesitter-textobjects.move')
    vim.keymap.set({ 'n', 'x', 'o' }, key, function() ts_move.goto_next_end(where, 'textobjects') end, { desc = desc })
end

ts_move_start_keymap(']m', '@function.outer', 'Move to next function')
ts_move_start_keymap(']]', '@class.outer', 'Move to next class')
ts_move_end_keymap(']M', '@function.outer', 'Move to function end')
ts_move_end_keymap('][', '@class.outer', 'Move to class end')

local function ts_select(key, where)
    vim.keymap.set({ 'x', 'o' }, key, function()
        require 'nvim-treesitter-textobjects.select'.select_textobject(where, 'textobjects')
    end)
end

ts_select('am', '@function.outer')
ts_select('im', '@function.inner')
ts_select('ac', '@class.outer')
ts_select('ic', '@class.outer')
ts_select('as', '@local.scope')

-- Blink (auto-completion)

require('blink.cmp').setup({
    fuzzy = { implementation = "prefer_rust_with_warning" },
    completion = {
        list = { selection = { preselect = false } },
    },
})


-- LSP and Mason (manage language server protocols)

vim.api.nvim_create_autocmd('LspAttach', {
    group = command_group,
    callback = function(event)
        local map = function(keys, func, desc)
            vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
        end

        map('gd',         FzfLua.lsp_definitions,       '[g]oto [d]efinition')
        map('gD',         FzfLua.lsp_declarations,      '[g]oto [D]eclaration')
        map('gr',         FzfLua.lsp_references,        '[g]oto [r]eferences')
        map('gi',         FzfLua.lsp_implementations,   '[g]oto [i]mplementation')
        map('<leader>ss', FzfLua.lsp_document_symbols,  '[s]earch document [s]ymbols')
        map('<leader>sS', FzfLua.lsp_workspace_symbols, '[s]earch workspace [S]ymbols')
        map('<leader>D',  FzfLua.lsp_typedefs,          'goto type [d]efinitions')
        map('<leader>cr', vim.lsp.buf.rename,           '[c]ode [r]ename')
        map('<leader>ca', vim.lsp.buf.code_action,      '[c]ode [a]ction')

        map('K', vim.lsp.buf.hover,          'hover documentation')
        map('S', vim.lsp.buf.signature_help, '[S]ignature help')

        vim.keymap.set(
            'i',
            '<C-s>',
            vim.lsp.buf.signature_help,
            { buffer = event.buf, desc = 'LSP: signature help' }
        )

        local client = vim.lsp.get_client_by_id(event.data.client_id)
        if client and client.server_capabilities.documentHighlightProvider == true then
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
                buffer = event.buf,
                callback = function()
                    pcall(vim.lsp.buf.document_highlight)
                end,
            })

            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
                buffer = event.buf,
                callback = function()
                    pcall(vim.lsp.buf.clear_references)
                end,
            })
        end

        if client then
            vim.keymap.set({ 'n', 'v' }, '<leader>cf', vim.lsp.buf.format, {desc = '[c]ode [f]ormat'})
        end

        -- Clangd extensions
        local function on_clangd_switch_source_header(err, uri)
            if not uri or uri == '' then
                vim.api.nvim_echo({ { 'No source/header found', 'WarningMsg' } }, true, {})
                return
            end
            local filename = vim.uri_to_fname(uri)
            vim.api.nvim_cmd({
                cmd = 'edit',
                args = { filename },
            }, {})
        end

        local function clangd_switch_source_header()
            vim.lsp.buf_request(0, 'textDocument/switchSourceHeader', {
                uri = vim.uri_from_bufnr(0),
            }, on_clangd_switch_source_header)
        end

        map('<leader>co', clangd_switch_source_header, 'switch source/header')
    end,
})

require('mason').setup({})

vim.lsp.config['*'] = { capabilities = require('blink.cmp').get_lsp_capabilities(), }
vim.lsp.config('lua_ls', {
    settings = {
        Lua = {
            diagnostics = { globals = { 'vim' } },
            telemetry = { enable = false },
        },
    },
})
vim.lsp.config('clangd', {
    cmd = {
        "clangd",
        "--background-index",
        "--j=8",
        "--suggest-missing-includes",
        "--clang-tidy",
        "--clang-tidy-checks=bugprone-*,cert-*,performance-*",
        "--all-scopes-completion",
        "--completion-style=detailed",
        "--header-insertion=iwyu",
        "--pretty",
        "--log=error",
    },
    init_options = {
        clangdFileStatus = true,
    },
})
vim.lsp.config('ols',   {})
vim.lsp.config('slang', {})
vim.lsp.config('zls', {
    cmd = { "zls" },
    filetypes = { "zig", "zon" },
})
vim.lsp.config('jsonls', {
    settings = { json = { validate = { enable = true } } },
})
vim.lsp.config('cmake', {})

vim.lsp.enable({
    'clangd',
    'lua_ls',
    'ols',
    'slang',
    'zls',
    'jsonls',
    'cmake',
})

-- TMUX (better integration with the terminal session)
require('tmux').setup({})

-- DAP (integrated debugger)

local dap = require('dap') local dapui = require('dapui') dapui.setup({ controls = { icons = { pause = '', play = '', step_into = '󰆹', step_over = '',
            step_out = '󰆸',
            step_back = '',
            run_last = '',
            terminate = '',
            disconnect = '',
        },
    },
    layouts = {
        {
            elements = {
                {
                    id = 'scopes',
                    size = 0.25
                }, {
                    id = 'breakpoints',
                    size = 0.25
                }, {
                    id = 'stacks',
                    size = 0.25
                }, {
                    id = 'watches',
                    size = 0.25
                }
            },
            position = 'left',
            size = 50,
        }, {
            elements = { {
                id = 'repl',
                size = 0.5
            }, {
                    id = 'console',
                    size = 0.5
                } },
            position = 'bottom',
            size = 20,
        }
    },
})

local dap_ext_vscode = require('dap.ext.vscode')
dap_ext_vscode.json_decode = require('json').decode

require('nvim-dap-virtual-text').setup({})

local is_windows = vim.loop.os_uname().sysname:find('Windows') and true or false
local codelldb_cmd = is_windows and 'codelldb.cmd' or 'codelldb'
local cwd = nil

local function set_dap_cwd()
    local new_dir = vim.fn.input({
        prompt     = 'Directory: ',
        default    = vim.fn.getcwd(),
        completion = 'dir',
    })
    if new_dir == nil or new_dir == '' then
        cwd = nil
    end
    cwd = new_dir
end

if vim.fn.executable('gdb') == 1 then
    local cpptools_ext = (is_windows and '.cmd') or ''
    dap.adapters.cpptools = {
        type    = 'executable';
        name    = 'cpptools',
        command = 'OpenDebugAD7',
        args    = {},
        attach  = {
            pidProperty = 'processId',
            pidSelect = 'ask'
        },
    }
end

dap.adapters.codelldb = {
    type = 'server',
    port = '${port}',
    executable = {
        command = vim.fn.stdpath('data') .. '/mason/bin/' .. codelldb_cmd,
        args = { '--port', '${port}' },
    },
}

local exe_launch_opts = {}
local make_launch_opts = function()
    exe_launch_opts.cmd = exe_launch_opts.cmd or vim.fn.getcwd() .. '/'
    local new_cmd = vim.fn.input('Command: ', exe_launch_opts.cmd, 'file')
    if new_cmd == nil or new_cmd == '' then
        return dap.ABORT
    end
    exe_launch_opts.cmd = new_cmd

    local args = vim.split(exe_launch_opts.cmd, ' ', { trimempty = true })
    exe_launch_opts.program = table.remove(args, 1)
    exe_launch_opts.args = args
    exe_launch_opts.has_program =
    exe_launch_opts.program ~= nil and
    vim.fn.executable(exe_launch_opts.program) == 1
end
local get_program = function()
    if not exe_launch_opts.has_program then
        make_launch_opts()
    end
    if vim.fn.executable(exe_launch_opts.program) == 0 then
        return dap.ABORT
    end
    return exe_launch_opts.program
end
local get_args = function()
    if not exe_launch_opts.has_program then
        make_launch_opts()
    end
    return exe_launch_opts.args
end

dap.configurations.cpp = {}
table.insert(dap.configurations.cpp, {
    name    = 'launch program (codelldb)',
    type    = 'codelldb',
    request = 'launch',
    program = get_program,
    args    = get_args,
    cwd     = function()
        return cwd or '${workspaceFolder}'
    end,
})
if vim.fn.executable('gdb') == 1 then
    table.insert(dap.configurations.cpp, {
        name =    'Launch program (gdb)',
        type =    'cpptools',
        request = 'launch',
        program = get_program,
        args =    get_args,
        cwd =     function()
            return cwd or '${workspaceFolder}'
        end,
    })
end
table.insert(dap.configurations.cpp, {
    name    = 'Attach ot process',
    type    = 'codellldb',
    request = 'attach',
    pid     = require('dap.utils').pick_process,
    args    = {},
})
table.insert(dap.configurations.cpp, {
    name        = 'Pause at start (codelldb)',
    type        = 'codelldb',
    request     = 'launch',
    program     = get_program,
    args        = get_args,
    cwd         = function()
        return cwd or '${workspaceFolder}'
    end,
    stopOnEntry = true,
})

dap.configurations.c    = dap.configurations.cpp
dap.configurations.rust = dap.configurations.cpp
dap.configurations.zig  = dap.configurations.cpp
dap.configurations.odin = dap.configurations.cpp
dap.configurations.d    = dap.configurations.cpp
dap.configurations.jai  = dap.configurations.cpp

dap.adapters.godot = {
    type = 'server',
    host = '127.0.0.1',
    port = 6006,
}

dap.configurations.gdscript = {
    {
        launch_game_instance = false,
        launch_scene         = false,
        name                 = 'Launch scene',
        project              = '${workspaceFolder}',
        request              = 'launch',
        type                 = 'godot',
    },
}

local dapui_open = function()
    dapui.open({ reset = true })
    vim.cmd('wincmd=')
end
local dapui_close = function()
    dapui.close()
    vim.cmd('DapVirtualTextForceRefresh')
    vim.cmd('wincmd=')
end
local dapui_toggle = function()
    dapui.toggle({ reset = true })
    vim.cmd('wincmd=')
end

dap.listeners.after.event_initialized['dapui_config'] = dapui_open
dap.listeners.before.event_terminated['dapui_config'] = dapui_close
dap.listeners.before.event_exited['dapui_config'] = dapui_close
dap.listeners.after.disconnect['dapui_config'] = dapui_close

local dap_ui_widgets = require('dap.ui.widgets')

local ok, wk = pcall(require, 'which-key')
if ok then
    wk.add({ '<leader>d', group = 'debug' })
end

local toggle_conditional_breakpoint = function()
    local condition = vim.fn.input('Condition: ')
    if condition then
        dap.toggle_breakpoint(condition)
    end
end

local set_program_and_run = function()
    exe_launch_opts.has_program = false
    dap.continue()
end

local dap_terminate_or_toggle_ui = function()
    if dap.session() ~= nil then
        dap.terminate()
    else
        dapui.close()
    end
end

vim.keymap.set('n', '<leader>dc', dap.continue, { desc = '[d]ebug [c]ontinue' })
vim.keymap.set('n', '<leader>dC', set_program_and_run, { desc = '[d]ebug [C]ontinue setup' })
vim.keymap.set('n', '<leader>dl', dap.run_last, { desc = '[d]ebug run [l]ast' })
vim.keymap.set('n', '<leader>dt', dap_terminate_or_toggle_ui, { desc = '[d]ebug [t]erminate' })
vim.keymap.set('n', '<leader>dr', dap.restart, { desc = '[d]ebug [r]estart' })
vim.keymap.set('n', '<leader>di', dap.step_into, { desc = '[d]ebug step [i]nto' })
vim.keymap.set('n', '<leader>ds', dap.step_over, { desc = '[d]ebug [s]tep over' })
vim.keymap.set('n', '<leader>dS', dap.step_back, { desc = '[d]ebug [S]tep back' })
vim.keymap.set('n', '<leader>do', dap.step_out, { desc = '[d]ebug step [o]ut' })
vim.keymap.set('n', '<leader>db', dap.toggle_breakpoint, { desc = '[d]ebug toggle [b]reakpoint' })
vim.keymap.set('n', '<leader>dB', toggle_conditional_breakpoint, { desc = '[d]ebug toggle conditional [B]reakpoint' })
vim.keymap.set('n', '<leader>dh', dap_ui_widgets.hover, { desc = '[d]ebug [h]over' })
vim.keymap.set('n', '<leader>dw', set_dap_cwd, { desc = '[d]ebug [w]orking d]irectory' })
vim.keymap.set('n', '<leader>drc', dap.run_to_cursor, { desc = '[d]ebug [r]un to [c]ursor' })

vim.keymap.set('n', '<F5>', dap.continue, { desc = 'debug continue' })
vim.keymap.set('n', '<S-F5>', dap.terminate, { desc = 'debug terminate' })
vim.keymap.set('n', '<M-S-F5>', dap.restart, { desc = 'debug continue' })

vim.keymap.set('n', '<F9>', dap.toggle_breakpoint, { desc = 'debug toggle breakpoint' })
vim.keymap.set('n', '<M-F9>', toggle_conditional_breakpoint, { desc = 'debug toggle conditional breakpoint' })
vim.keymap.set('n', '<F10>', dap.step_over, { desc = 'debug step over' })
vim.keymap.set('n', '<M-F10>', dap.step_back, { desc = 'debug step back' })
vim.keymap.set('n', '<F11>', dap.step_into, { desc = 'debug step into' })
vim.keymap.set('n', '<M-F11>', dap.step_out, { desc = 'debug step out' })

local eval_at_cursor = function()
    dapui.eval(nil, { enter = true })
end
local eval_expr = function()
    dapui.eval(vim.fn.input('Expression: '))
end

vim.keymap.set('n', '<leader>du', dapui_toggle, { desc = '[d]ebug [u]i toggle' })
vim.keymap.set('n', '<leader>de', eval_at_cursor, { desc = '[d]ebug [e]val under the cursor' })
vim.keymap.set('n', '<leader>dx', eval_expr, { desc = '[d]ebug eval e[x]pression' })

-- Terminal based markdown rendering
require('render-markdown').setup({
    completions = { lsp = { enabled = true } },
    file_types = { 'markdown', 'Avante', 'codecompanion' }
})

-- Gitsigns (git info in the gutter and inline)
require('gitsigns').setup({ current_line_blame = true })

-- Codediff (better diff views)
require('codediff').setup({})

-- HL-comments (my own plugin to highlight TODO comments)
require('hl-comments').setup({})

