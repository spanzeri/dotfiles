--[[
███████╗ █████╗ ███╗   ███╗███████╗    ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
██╔════╝██╔══██╗████╗ ████║██╔════╝    ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
███████╗███████║██╔████╔██║███████╗    ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
╚════██║██╔══██║██║╚██╔╝██║╚════██║    ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
███████║██║  ██║██║ ╚═╝ ██║███████║    ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝╚══════╝    ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝
--]]

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

vim.cmd('colorscheme gruber-darker')
vim.api.nvim_set_hl(0, "Normal", { bg = nil })
vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter", "WinEnter" },
    {
        callback = function()
            vim.api.nvim_set_hl(0, "Normal", { bg = nil })
        end,
        group = vim.api.nvim_create_augroup("hl-fix", { clear = true }),
        pattern = "*",
        desc = "Ensure the background is transparent",
    })

