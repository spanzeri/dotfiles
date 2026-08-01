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

-- Replacement for default input (floating window instead of command line)
vim.ui.input = function(opts, on_confirm)
    local prompt  = opts.prompt or 'Input: '
    local default = opts.default or ''

    -- Create a small scratch buffer
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, { default })

    -- Open a floating window
    local win = vim.api.nvim_open_win(buf, true, {
        relative = 'cursor',
        row      = 1, col = 0,
        width    = math.max(20, #prompt + #default + 10),
        height   = 1,
        border   = 'rounded',
        title    = prompt,
        style    = 'minimal',
    })

    -- Keymaps to confirm or cancel
    local function close() vim.api.nvim_win_close(win, true) end

    vim.keymap.set('i', '<CR>', function()
        local input = vim.api.nvim_buf_get_lines(buf, 0, -1, false)[1]
        close()
        on_confirm(input)
    end, { buffer = buf })

    vim.keymap.set('n', '<Esc>', close, { buffer = buf })
    vim.cmd("startinsert!")
end

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

require('vs-dark').setup({
    transparent = true,
    italic = false,
})
vim.cmd('colorscheme vs-dark')

vim.api.nvim_set_hl(0, "Normal", { bg = nil })
vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter" },
    {
        callback = function()
            vim.api.nvim_set_hl(0, "Normal", { bg = nil })
        end,
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
