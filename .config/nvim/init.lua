--[[
███████╗ █████╗ ███╗   ███╗███████╗    ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
██╔════╝██╔══██╗████╗ ████║██╔════╝    ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
███████╗███████║██╔████╔██║███████╗    ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
╚════██║██╔══██║██║╚██╔╝██║╚════██║    ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
███████║██║  ██║██║ ╚═╝ ██║███████║    ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝╚══════╝    ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝
--]]

-- Enable the new experimental UI
require('vim._core.ui2').enable({})

vim.g.mapleader      = ' '
vim.g.maplocalleader = ' '

require('options')
require('plugins')
require('keybinds')

local command_group = vim.api.nvim_create_augroup('SamConfig-Init', { clear = true })

vim.api.nvim_create_autocmd('TextYankPost', {
    callback = function() vim.highlight.on_yank() end,
    group = command_group,
})

-- Reload files changed outside of nvim (needs 'autoread', see options.lua)
vim.api.nvim_create_autocmd({ 'FocusGained', 'BufEnter', 'CursorHold', 'CursorHoldI', 'TermLeave' },
    {
        callback = function()
            -- checktime errors out in the command-line window and is pointless
            -- for buffers not backed by a file (terminals, scratch, ...)
            if vim.fn.getcmdwintype() ~= '' then return end
            if vim.bo.buftype ~= '' then return end
            vim.cmd('checktime')
        end,
        group = command_group,
        desc = 'Check for external file changes',
    })

vim.api.nvim_create_autocmd('FileChangedShellPost',
    {
        callback = function()
            vim.notify('File changed on disk, buffer reloaded', vim.log.levels.WARN)
        end,
        group = command_group,
        desc = 'Warn when a buffer got reloaded from disk',
    })

require('vs').setup({
    transparent = true,
    italic = false,
})

-- Before the first :colorscheme, or it loads twice.
vim.o.background = require('theme').read()
vim.cmd('colorscheme vs')

vim.api.nvim_create_autocmd('Signal', {
    pattern = 'SIGUSR1',
    callback = function() require('theme').sync() end,
    group = command_group,
    -- The reload re-sources the colorscheme, whose ColorScheme autocmd is what
    -- rebuilds every plugin's derived highlights; without this it is nested
    -- inside this one and skipped (:h autocmd-nested).
    nested = true,
    desc = 'Follow the terminal light/dark switch',
})

-- { bg = nil } would replace the group and drop fg too.
local function clear_normal_bg()
    local hl = vim.api.nvim_get_hl(0, { name = "Normal", link = false })
    if hl.bg ~= nil then
        hl.bg = nil
        vim.api.nvim_set_hl(0, "Normal", hl)
    end
end

clear_normal_bg()
vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter", "ColorScheme" },
    {
        callback = clear_normal_bg,
        group = vim.api.nvim_create_augroup("hl-fix", { clear = true }),
        pattern = "*",
        desc = "Ensure the background is transparent",
    })

vim.api.nvim_create_autocmd({ 'WinEnter', 'BufEnter' },
    {
        callback = function()
            vim.bo.formatoptions = 'tcqjr'
        end,
        group = command_group,
        desc = 'Options to set when opening or entering a buffer',
    })


vim.api.nvim_create_autocmd({ 'WinEnter', 'BufEnter' },
    {
        callback = function()
            if vim.bo.filetype == 'dapui_console' then
                vim.wo.wrap = true
            end
        end,
        group = command_group,
        desc = 'Options to set when opening or entering a buffer',
    })

-- Another session's swap is a sibling of ours: we get pushed to .swo, .swn, ...
local function other_swaps()
    local file = vim.api.nvim_buf_get_name(0)
    if file == '' then return {} end
    local own  = vim.fn.swapname(0)
    local stem = own ~= '' and own:sub(1, -5)
        or vim.o.directory:gsub('/+$', '') .. '/' .. vim.fn.fnamemodify(file, ':p'):gsub('/', '%%')
    return vim.tbl_filter(function(swap) return swap ~= own end, vim.fn.glob(stem .. '.*', false, true))
end

local function diff_swap(swap)
    -- 'recover' reads a swap only from 'directory', so recover a copy of it.
    local dir = vim.fn.tempname()
    local out = dir .. '/recovered'
    vim.fn.mkdir(dir, 'p')
    vim.uv.fs_copyfile(swap, dir .. '/' .. vim.fn.fnamemodify(swap, ':t'))
    vim.fn.system({
        vim.v.progpath, '--headless', '-u', 'NONE', '-n',
        '--cmd', 'set directory=' .. vim.fn.escape(dir, ' \\') .. '//',
        '-c', 'silent! recover ' .. vim.fn.fnameescape(vim.api.nvim_buf_get_name(0)),
        '-c', 'silent! write! ' .. vim.fn.fnameescape(out),
        '-c', 'qa!',
    })
    local lines = vim.fn.filereadable(out) == 1 and vim.fn.readfile(out)
    vim.fn.delete(dir, 'rf')
    if not lines then
        vim.notify('Could not recover ' .. swap, vim.log.levels.ERROR)
        return
    end

    local origin = vim.api.nvim_get_current_win()
    local ft     = vim.bo.filetype
    vim.cmd('vnew')
    local buf = vim.api.nvim_get_current_buf()
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.bo[buf].buftype   = 'nofile'
    vim.bo[buf].bufhidden = 'wipe'
    vim.bo[buf].swapfile  = false
    vim.bo[buf].filetype  = ft
    vim.api.nvim_buf_set_name(buf, '[swap] ' .. vim.fn.fnamemodify(swap, ':t'))
    vim.cmd('diffthis')
    vim.api.nvim_set_current_win(origin)
    vim.cmd('diffthis')
    vim.api.nvim_create_autocmd('BufWipeout', {
        buffer = buf, once = true,
        callback = function()
            if vim.api.nvim_win_is_valid(origin) then vim.wo[origin].diff = false end
        end,
    })
end

vim.api.nvim_create_user_command('SwapDiff', function()
    local swaps = other_swaps()
    if #swaps == 0 then
        vim.notify('No swap file for ' .. vim.api.nvim_buf_get_name(0), vim.log.levels.WARN)
    elseif #swaps == 1 then
        diff_swap(swaps[1])
    else
        vim.ui.select(swaps, { prompt = 'Swap file to diff:' }, function(swap)
            if swap ~= nil then diff_swap(swap) end
        end)
    end
end, { desc = "Diff the buffer against another session's swap file" })

vim.api.nvim_create_user_command('SwapDelete', function(opts)
    local swaps = other_swaps()
    if #swaps == 0 then
        vim.notify('No swap file for ' .. vim.api.nvim_buf_get_name(0), vim.log.levels.WARN)
        return
    end
    if not opts.bang
        and vim.fn.confirm('Delete swap file(s)?\n' .. table.concat(swaps, '\n'), '&Yes\n&No', 2) ~= 1 then
        return
    end
    for _, swap in ipairs(swaps) do
        local ok = vim.fn.delete(swap) == 0
        vim.notify((ok and 'Deleted ' or 'Could not delete ') .. swap,
            ok and vim.log.levels.INFO or vim.log.levels.ERROR)
    end
end, { bang = true, desc = 'Delete swap files left by other sessions' })
