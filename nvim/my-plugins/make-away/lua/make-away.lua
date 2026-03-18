local M = {}

--
-- Configuration
--

---@class MakeAwayConfig.window
---@field title string Title that will be displayed for the compilation window
---@field border "none"|"single"|"double"|"rounded" Border style
---@field height number <= 1 percentage of the editor window height. >1 amount of rows
---@field width number <=1 percentage of the editor window height. > 1 amount of rows.
--- This value is ignored unless the position is "float"
---@field position "bottom"|"float" where the window should appear (default: "bottom")

---@class MakeAwayConfig
---@field window MakeAwayConfig.window Window appearance options
---@field autoclose boolean whether the compilation window should auto-close on compilation success
---@field dismiss_time_ms number Number of milliseconds to wait before closing
--- the compilation window (default: 3000)
---@field autosave_before boolean Save all (named) open buffers before compiling (default: true)


---@type MakeAwayConfig
M.config = {
    window = {
        title    = " *compilation* ",
        border   = "rounded",
        height   = 30,
        width    = 0.8,
        position = "bottom",
    },
    autoclose = false,
    dismiss_time_ms = 3000,
    autosave_before = true,
}

---Setup make-away configuration.
---@param opts? MakeAwayConfig Optional config
function M.setup(opts)
    M.config = vim.tbl_deep_extend("force", M.config, opts or {})
    vim.api.nvim_create_user_command("Make", M.make, {})
end

--
-- Window management
--

local state = {
    bufnr = nil,
    winnr = nil,
    lines = {},
}

local function is_compile_window_open()
    return state.winnr and vim.api.nvim_win_is_valid(state.winnr)
end

local function compute_size(value, total)
    if value <= 1 then
        return math.floor(total * value)
    end
    return value
end

local function compute_window_rect()
    local width = compute_size(M.config.window.width, vim.o.columns)
    local height = compute_size(M.config.window.height, vim.o.lines)

    local row = math.floor((vim.o.lines - height) / 2)
    local col = math.floor((vim.o.columns - width) / 2)

    return row, col, width, height
end

local function create_compile_window()
    local row, col, width, height = compute_window_rect()

    if M.config.window.position == "float" then
        return vim.api.nvim_open_win(state.bufnr, false, {
            relative = "editor",
            row       = row,
            col       = col,
            width     = width,
            height    = height,
            style     = "minimal",
            border    = M.config.window.border,
            title     = M.config.window.title,
            title_pos = "center",
        })
    end

    height = math.max(M.config.window.border == "none" and 1 or 3, math.min(height, vim.o.lines))

    -- HACK(Sam): This might cause problems. But I don't want both qflist and
    -- compilation window to show up at the same time if the compilation window
    -- isn't floating
    vim.cmd("cclose")
    vim.cmd("botright split")
    local winnr = vim.api.nvim_get_current_win()
    vim.cmd("wincmd p")

    vim.api.nvim_win_set_buf(winnr, state.bufnr)
    vim.api.nvim_win_set_height(winnr, height)

    return winnr
end

local function open_compile_window()
    if is_compile_window_open() then
        return
    end

    if not state.bufnr or not vim.api.nvim_buf_is_valid(state.bufnr) then
        state.bufnr = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_name(state.bufnr, M.config.window.title)
        vim.bo[state.bufnr].bufhidden = "hide" -- keep buffer alive when window closes
    end

    state.winnr = create_compile_window()
    vim.wo[state.winnr].wrap = true

    vim.keymap.set("n", "q", function() M.close() end, { buffer = state.bufnr, silent = true })
end

---Closes the compilation window if it was currently opened
function M.close()
    if is_compile_window_open() then
        vim.api.nvim_win_close(state.winnr, true)
        state.winnr = nil
    end
end

---Open the compilation window if it was closed, or opens it otherwise.
function M.toggle()
    if is_compile_window_open() then
        M.close()
    else
        open_compile_window()

        -- Scroll to the end
        local lc = vim.api.nvim_buf_line_count(state.bufnr)
        if lc > 0 then
            vim.api.nvim_win_set_cursor(state.winnr, { lc, 0 })
        end
    end
end

--
-- Make
--

local job_state = {
    dismiss_timer = nil,
    job = nil,
    start_time = nil,
}

local function start_make_time()
    job_state.start_time = vim.loop.hrtime()
end

---@return number Minutes, number Seconds, number Milliseconds
local function get_make_total_time()
    if job_state.start_time == nil then
        return 0, 0, 0
    end

    local elapsed = (vim.loop.hrtime() - job_state.start_time) / 1e6
    local min = math.floor(elapsed / 60000)
    local sec = math.floor((elapsed % 60000) / 1000)
    local ms  = math.floor(elapsed % 1000)

    return min, sec, ms
end

---Run the make command asynchronously. See ':makeprg'
function M.make()
    local caller_winnr = vim.api.nvim_get_current_win()
    local caller_bufnr = vim.api.nvim_win_get_buf(caller_winnr)

    local function get_local_or_global_opt(name)
        local opt = vim.api.nvim_get_option_value(name, { buf = caller_bufnr })
        if opt == "" then
            opt = vim.api.nvim_get_option_value(name, {})
        end
        return opt
    end

    if M.config.autosave_before then
        vim.cmd("silent! wa")
    end

    local makeprg = get_local_or_global_opt("makeprg")
    local errorfmt = get_local_or_global_opt("errorformat")
    if makeprg == nil or makeprg == "" then
        vim.notify("Missing compilation command. Use `:set makeprg=` to define one", vim.log.levels.ERROR, {})
        return
    end

    if job_state.dismiss_timer then
        job_state.dismiss_timer:stop()
        job_state.dismiss_timer = nil
    end

    if job_state.job ~= nil then
        vim.ui.select(
            { "Yes", "No" },
            { prompt = "A compilation process is already running. Do you want to kill it?" },
            function(choice)
                if choice == "Yes" and job_state.job then
                    job_state.job:kill(9)
                    job_state.job = nil
                end
            end)
    end

    open_compile_window()
    -- Make sure the buffer is empty, we might be re-using it
    vim.api.nvim_buf_set_lines(state.bufnr, 0, -1, false, {})

    local cmd = vim.fn.expandcmd(makeprg)

    local function append_line(data)
        if not (state.bufnr and vim.api.nvim_buf_is_valid(state.bufnr)) then
            return
        end
        vim.list_extend(state.lines, data)
        vim.api.nvim_buf_set_lines(state.bufnr, -1, -1, false, data)
        if is_compile_window_open() then
            local lc = vim.api.nvim_buf_line_count(state.bufnr)
            vim.api.nvim_win_set_cursor(state.winnr, { lc, 0 })
        end
    end

    local function trim(str)
        return (str:gsub("^%s*(.-)%s*$", "%1"))
    end

    local function append_fast_context(_, message)
        if message then
            vim.schedule(function()
                local lines = vim.split(message, "\n", { plain = true, trimempty = true })
                append_line(lines)
            end)
        end
    end

    vim.api.nvim_command("doautocmd QuickFixCmdPre")
    start_make_time()
    job_state.job = vim.system(
        { cmd },
        {
            stdout = append_fast_context,
            stderr = append_fast_context,
            text = true,
        },
        function()
            vim.schedule(function()
                job_state.job = nil

                vim.fn.setqflist({}, " ", {
                    title = cmd,
                    lines = state.lines,
                    efm   = errorfmt,
                })
                vim.api.nvim_command("doautocmd QuickFixCmdPost")
                state.lines = {}

                local qf = vim.fn.getqflist()
                local has_errors = vim.iter(qf):any(function(item)
                    print("Item type: "..item.type)
                    return string.lower(item.type) == "e" or string.lower(item.type) == "w"
                end)

                local elapsed_m, elapsed_s, elapsed_ms = get_make_total_time()
                local time_str = ("%d min %d sec %d ms"):format(elapsed_m, elapsed_s, elapsed_ms)

                if has_errors then
                    append_line({ "", "-- Compilation FAILED: "..time_str.." --" })
                    vim.schedule(function()
                        M.close()
                        local curr_win = vim.api.nvim_get_current_win()
                        vim.cmd([[botright cwindow]] .. compute_size(M.config.window.height, vim.o.lines))
                        vim.api.nvim_set_current_win(curr_win)
                    end)
                else
                    append_line({ "", "-- Compilation succeeded: "..time_str.." --" })
                    if M.config.autoclose then
                        job_state.dismiss_timer = vim.defer_fn(function()
                            M.close()
                            job_state.dismiss_timer = nil
                        end, M.config.dismiss_time_ms or 3000)
                    end
                end

                vim.api.nvim_echo(
                    {{ "Compilation completed in:" .. time_str, has_errors and "DiagnosticWarn" or "DiagnosticNote" }},
                    false,
                    {})
            end)
        end)
end

return M
