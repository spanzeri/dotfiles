-- =============================================================================
-- Keybinds
-- =============================================================================

-- Exit vim mode with jj
vim.keymap.set('i', 'jj', [[<Esc>]])

-- Exit terminal with esc+esc (it won't work in every terminal, tmux etc).
-- When it does not work, <C-\><C-n> can still be used
vim.keymap.set('t', '<Esc><Esc>', [[<C-\><C-n>]])

-- Disable search highlight on escape pressed
vim.keymap.set('n', '<Esc>', [[<cmd>nohlsearch<CR>]])

-- Ctrl+Del and Ctrl+BS in insert mode
vim.keymap.set('i', '<C-del>', [[<C-o>dw]])
vim.keymap.set('i', '<C-BS>', [[<C-o>db]])

-- Move visual selection up and down
vim.keymap.set('v', 'J', ':m \'>+1<CR>gv=gv')
vim.keymap.set('v', 'K', ':m \'<-2<CR>gv=gv')

-- Better movement
vim.keymap.set('n', 'k', [[v:count == 0? 'gk' : 'k']], { expr = true, silent = true })
vim.keymap.set('n', 'j', [[v:count == 0? 'gj' : 'j']], { expr = true, silent = true })
vim.keymap.set('n', '<C-d>', [[<C-d>zz]])
vim.keymap.set('n', '<C-u>', [[<C-u>zz]])
vim.keymap.set('n', 'n', [[nzz]])
vim.keymap.set('n', 'N', [[Nzz]])

-- Indent keeping selection
vim.keymap.set('v', '<', '<gv', { desc = 'Indent left and reselect' })
vim.keymap.set('v', '>', '>gv', { desc = 'Indent right and reselect' })

-- Copy to clipboard
vim.keymap.set('v', '<leader>y', [['+y]],  { desc = 'Copy to system clipboard' })
vim.keymap.set('x', '<leader>p', [['_dP]], { desc = 'Paste without yanking' })
vim.keymap.set({ 'n', 'v' }, '<leader>x', [['_d]], { desc = 'Delete without yanking' })

-- Diagnostic keymaps

local diagnostic_float = function(count)
    return function()
        vim.diagnostic.jump {
            count = count,
            float = true,
        }
    end
end

vim.keymap.set('n', '<leader>ef', vim.diagnostic.open_float, { desc = 'Show diagnostic [f]loat' })
vim.keymap.set('n', '<leader>el', vim.diagnostic.setloclist, { desc = 'Move diagnostics to [l]oclist' })
vim.keymap.set('n', '<leader>ee', vim.cmd.cc, { desc = 'go to first [e]rror' })
vim.keymap.set('n', '<leader>en', vim.cmd.cn, { desc = 'go to [e]rror [n]ext' })
vim.keymap.set('n', '<leader>ep', vim.cmd.cp, { desc = 'go to [e]rror [p]rev' })
vim.keymap.set('n', '<leader>eo', [[<cmd>botright copen 30 | wincmd p<CR>]], { desc = '[e]rrors [o]pen' })
vim.keymap.set('n', '<leader>ec', vim.cmd.cclose, { desc = '[e]rrors [c]lose' })

local toggle_errors = function()
    local ewinid = vim.fn.getqflist({ winid = 0 }).winid
    if ewinid == 0 then
        vim.cmd [[botright copen | wincmd p]]
    else
        vim.cmd [[cclose]]
    end
end

vim.keymap.set('n', '<leader>et', toggle_errors, { desc = '[e]rrors [t]oggle' })

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- Save and source lua
vim.keymap.set('n', '<leader>xx', [[<cmd>w | so<CR>]], { desc = 'Write and source file' })

-- Compilation

local set_mkprg = function()
    local prev_mp = vim.o.makeprg
    local mp = vim.fn.input({
        prompt     = 'Make command: ',
        default    = prev_mp,
        completion = 'compiler'
    })
    if mp ~= nil and mp ~= '' then
        vim.o.makeprg = mp
    end
end

vim.keymap.set('n', '<leader>ms', set_mkprg, { desc = '[m]ake [s]et' })

local has_make_plugin, make_away = pcall(require, 'make-away')
if not has_make_plugin then
    local make_and_qf_open_on_error = function()
        -- Save the current window so we can make sure to re-select it
        local curr_win = vim.api.nvim_get_current_win()
        -- This saves all files (wa), runs the make command and open the qf list if
        -- there are errors, closes it otherwise.
        vim.cmd [[silent! wa | make | botright cwindow 32]]
        vim.api.nvim_set_current_win(curr_win)
    end
    vim.keymap.set('n', '<leader>mm', make_and_qf_open_on_error, { desc = '[m]ake [m]ake' })
else
    -- Use my make-away plugin
    vim.keymap.set('n', '<leader>mm', make_away.make,   { desc = '[m]ake' })
    vim.keymap.set('n', '<leader>mt', make_away.toggle, { desc = '[m]ake [t]oggle window' })
end


-- ===============================================
-- Lazygit
-- ===============================================

local lazygit = {
    buf = nil,
    win = nil,
    job = nil,
}

local function lazygit_job_running()
    if lazygit.job == nil then
        return false
    end
    return vim.fn.jobwait({ lazygit.job }, 0)[1] == -1
end

local function lazygit_reset_state()
    lazygit.buf = nil
    lazygit.win = nil
    lazygit.job = nil
end

local function lazygit_close_window()
    if lazygit.win ~= nil and vim.api.nvim_win_is_valid(lazygit.win) then
        vim.api.nvim_win_close(lazygit.win, true)
    end
    lazygit.win = nil
end

local function lazygit_kill()
    lazygit_close_window()

    if lazygit_job_running() then
        vim.fn.jobstop(lazygit.job)
    end

    if lazygit.buf ~= nil and vim.api.nvim_buf_is_valid(lazygit.buf) then
        vim.api.nvim_buf_delete(lazygit.buf, { force = true })
    end

    lazygit_reset_state()
end

local function lazygit_open_float(buf)
    local width = math.floor(vim.o.columns * 0.9)
    local height = math.floor(vim.o.lines * 0.9)
    local row = math.floor((vim.o.lines - height) / 2)
    local col = math.floor((vim.o.columns - width) / 2)

    lazygit.win = vim.api.nvim_open_win(buf, true, {
        relative = 'editor',
        width = width,
        height = height,
        row = row,
        col = col,
        style = 'minimal',
        border = 'rounded',
    })

    vim.keymap.set('n', 'q', lazygit_kill, { buffer = buf, silent = true, nowait = true })
end

local function lazygit_toggle()
    if vim.fn.executable('lazygit') == 0 then
        vim.notify('lazygit is not installed or not in $PATH', vim.log.levels.ERROR)
        return
    end

    if lazygit.win ~= nil and vim.api.nvim_win_is_valid(lazygit.win) then
        lazygit_close_window()
        return
    end

    if lazygit.buf ~= nil and vim.api.nvim_buf_is_valid(lazygit.buf) and lazygit_job_running() then
        lazygit_open_float(lazygit.buf)
        vim.cmd.startinsert()
        return
    end

    lazygit.buf = vim.api.nvim_create_buf(false, true)
    vim.bo[lazygit.buf].bufhidden = 'hide'
    vim.bo[lazygit.buf].filetype = 'lazygit'

    lazygit_open_float(lazygit.buf)
    lazygit.job = vim.fn.termopen('lazygit', {
        on_exit = function()
            vim.schedule(function()
                lazygit_kill()
            end)
        end,
    })
    vim.cmd.startinsert()
end

vim.keymap.set('n', '<leader>tl', lazygit_toggle, { desc = '[t]oggle [l]azygit' })

