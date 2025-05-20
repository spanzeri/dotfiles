--[[
TODO:
 [ ] Make default terminal (no commands) permanent
 [ ] Use a scratch for command execution and close on exit
--]]

local M = {}

local state = {
    buf = nil,
    win = nil,
    cmd = nil,
}

---@table default_opts table: Default options for smp.term
local default_config = {
    width = 0.8,
    height = 0.8,
}


--- Setup function for smp.term
--- Options:
---  width: the default width of the terminal window as a 0..1 percentage of the screen.
---  height: the default height of the terminal window as a 0..1 percentage of the screen.
---@param opts table: Options for smp.term.
M.setup = function(opts)
    M.config = opts or {}
    M.config = vim.tbl_extend("force", default_config, opts)
end


--- Open a terminal in a floating window
--- Options:
---  * width: the width of the terminal window as a 0..1 percentage of the screen.
---  * height: the height of the terminal window as a 0..1 percentage of the screen.
---  * command: string: an optional command to run in the terminal.
---  * close_on_leave_insert: bool: whether to close the terminal when leaving insert mode.
---  * close_on_error: bool: whether to close the terminal when the command exits with an error.
---@param opts table: Options
M.open = function(opts)
    opts = opts or {}
    local w = opts.width  or M.config.width
    local h = opts.height or M.config.height

    local cmd = opts.command
    if cmd and type(cmd) == "string" and cmd:len() > 0 then
        if vim.fn.executable(cmd) == 0 then
            vim.api.nvim_notify("Command not found: " .. cmd, vim.log.levels.ERROR, {})
            return
        end
    else
        cmd = nil
    end

    local bufnr = state.buf
    local needs_new_term = false
    if bufnr and vim.api.nvim_buf_is_valid(bufnr) and state.cmd ~= cmd then
        vim.api.nvim_buf_delete(bufnr, { force = true })
        bufnr = nil
        needs_new_term = true
    end

    if bufnr == nil or not vim.api.nvim_buf_is_valid(bufnr) then
        bufnr = vim.api.nvim_create_buf(false, true)
        needs_new_term = true
    end

    local winnr = state.win
    if winnr == nil or not vim.api.nvim_win_is_valid(winnr) then
        winnr = vim.api.nvim_open_win(bufnr, true, {
            relative = "editor",
            width    = math.floor(vim.o.columns * w),
            height   = math.floor(vim.o.lines * h),
            row      = math.floor((vim.o.lines * (1 - h)) / 2),
            col      = math.floor((vim.o.columns * (1 - w)) / 2),
            style    = "minimal",
            border   = "single",
        })
    end

    if nil == nil then print("nil") end

    -- Set the current window and enter insert mode
    vim.api.nvim_set_current_win(winnr)
    vim.api.nvim_set_current_buf(bufnr)

    if needs_new_term then
        vim.cmd.terminal(cmd)
    end

    vim.cmd "startinsert"

    local events = { "TermClose" }
    local desc = "Close terminal when term is closed"
    if opts.close_on_leave_insert then
        table.insert(events, "TermLeave")
        desc = desc .. " or when leaving insert mode"
    end

    vim.api.nvim_create_autocmd(events, {
        buffer = bufnr,
        group = vim.api.nvim_create_augroup("smp-term-close", { clear = true }),
        desc = desc,
        callback = function()
            local exit_code = vim.v.event.status
            local should_close = exit_code ~= 0 or opts.close_on_leave_insert
            if should_close then
                if state.win and vim.api.nvim_win_is_valid(state.win) then
                    vim.api.nvim_win_close(state.win, true)
                    state.win = nil
                end
            end
        end,
    })

    state.buf = bufnr
    state.win = winnr
    state.cmd = cmd
end

return M
