local state = {}

local create_float_popup = function(bufnr)
    if state.float and state.float.win and vim.api.nvim_win_is_valid(state.float.win) then
        return state.float
    end

    local width = math.floor(vim.o.columns * 0.8)
    local height = math.floor(vim.o.lines * 0.8)

    local col = math.floor((vim.o.columns - width) / 2)
    local row = math.floor((vim.o.lines - height) / 2)

    -- Unlisted scratch buffer
    print("Bufnr: " .. vim.inspect(bufnr))
    local buf = bufnr or vim.api.nvim_create_buf(false, true)

    local win_config = {
        relative = "editor",
        width = width,
        height = height,
        col = col,
        row = row,
        style = "minimal",
        border = "rounded",
    }

    local win = vim.api.nvim_open_win(buf, true, win_config)

    vim.api.nvim_create_autocmd("TermClose", {
        buffer = buf,
        group = vim.api.nvim_create_augroup("floatterm-close", { clear = true }),
        desc = "Close float when term is closed",
        callback = function()
            local exit_code = vim.v.event.status
            if exit_code ~= 0 then
                print("Command exited unsuccesfully with code " .. exit_code)
            end
            vim.api.nvim_win_close(win, true)
            state.float.win = nil
        end,
    })

    state.float = { buf = buf, win = win }
    return state.float
end

local open_floatterm = function()
    local buf = nil
    if state.float and state.float.buf and vim.api.nvim_buf_is_valid(state.float.buf) then
        buf = state.float.buf
    end
    local float = create_float_popup(buf)
    vim.api.nvim_set_current_win(float.win)
    if not buf then
        vim.cmd("terminal")
    end
    vim.cmd.startinsert()
end

local has_lazygit = false

local open_lazygit = function()
    has_lazygit = has_lazygit or vim.fn.executable("lazygit") == 1
    if not has_lazygit then
        print("Lazygit is not installed")
        return
    end

    local buf = nil
    if state.float and state.float.buf and vim.api.nvim_buf_is_valid(state.float.buf) then
        buf = state.float.buf
    end
    local float = create_float_popup(buf)
    vim.api.nvim_set_current_win(float.win)
    if not buf then
        vim.fn.termopen("lazygit")
    end

    vim.api.nvim_create_autocmd("TermLeave", {
        buffer = buf,
        group = vim.api.nvim_create_augroup("lazygit-leave", { clear = true }),
        desc = "Close float when leaving terminal mode",
        callback = function()
            if float.buf and vim.api.nvim_buf_is_valid(float.buf) then
                vim.api.nvim_buf_delete(float.buf, { force = true })
                state.float.buf = nil
            end

            if float.win and vim.api.nvim_win_is_valid(float.win) then
                vim.api.nvim_win_close(float.win, true)
                state.float = nil
            end
        end,
    })

    vim.cmd.startinsert()
end

vim.api.nvim_create_user_command("Lazygit", open_lazygit, {})
vim.api.nvim_set_keymap("n", "<leader>lg", ":Lazygit<CR>", { noremap = true, silent = true })

vim.keymap.set("n", "<leader>ft", open_floatterm, { noremap = true, silent = true })
