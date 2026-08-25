-- Follows the terminal's light/dark state, which `theme-toggle` writes to a
-- file and announces with SIGUSR1.

local M = {}

local state_file = (vim.env.XDG_STATE_HOME or (vim.env.HOME .. '/.local/state')) .. '/theme'

function M.read()
    local f = io.open(state_file, 'r')
    if not f then return 'dark' end
    local line = f:read('l')
    f:close()
    return vim.trim(line or '') == 'light' and 'light' or 'dark'
end

-- Assigning 'background' re-sources the active colorscheme (:h 'background'),
-- which is what actually swaps the palette; guard it so a redundant signal
-- doesn't cost a reload.
function M.sync()
    local bg = M.read()
    if vim.o.background ~= bg then
        vim.o.background = bg
    end
end

return M
