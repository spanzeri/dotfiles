-- theme-toggle records the theme in the tmux session; the file is the fallback.

local M = {}

local state_file = (vim.env.XDG_STATE_HOME or (vim.env.HOME .. '/.local/state')) .. '/theme'

local function session_theme()
    if not vim.env.TMUX then return nil end
    local out = vim.fn.system({ 'tmux', 'show-environment', 'TERM_BACKGROUND' })
    if vim.v.shell_error ~= 0 then return nil end
    local mode = out:match('^TERM_BACKGROUND=(%a+)')
    if mode == 'light' or mode == 'dark' then return mode end
    return nil
end

local function file_theme()
    local f = io.open(state_file, 'r')
    if not f then return 'dark' end
    local line = f:read('l')
    f:close()
    return vim.trim(line or '') == 'light' and 'light' or 'dark'
end

function M.read()
    return session_theme() or file_theme()
end

-- Assigning 'background' re-sources the colorscheme (:h 'background'). sync() reads
-- only the session: one that was never switched must not follow another window's toggle.
function M.sync()
    local bg = session_theme()
    if bg and vim.o.background ~= bg then
        vim.o.background = bg
    end
end

return M
