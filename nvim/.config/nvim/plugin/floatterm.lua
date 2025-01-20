local state = {}

local create_term_float = function()
    if state.float and
        vim.api.nvim_buf_is_valid(state.float.buf) and
        vim.api.nvim_win_is_valid(state.float.win)
    then
        return state.float
    end

    local width = math.floor(vim.o.columns * 0.8)
    local height = math.floor(vim.o.lines * 0.8)

    local col = math.floor((vim.o.columns - width) / 2)
    local row = math.floor((vim.o.lines - height) / 2)

    -- Unlisted scratch buffer
    local buf = vim.api.nvim_create_buf(false, true)

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

    state.float = { buf = buf, win = win }
    return state.float
end

local has_lazygit = false

local open_lazygit = function()
    has_lazygit = has_lazygit or vim.fn.executable("lazygit") == 1
    if not has_lazygit then
        print("Lazygit is not installed")
        return
    end

    local float = create_term_float()
    vim.api.nvim_set_current_win(float.win)
    vim.fn.termopen("lazygit")

    vim.api.nvim_create_autocmd("TermClose", {
        buffer = float.buf,
        group = vim.api.nvim_create_augroup("lazygit-close", { clear = true }),
        desc = "Close float when lazygit exits",
        callback = function()
            local exit_code = vim.v.event.status
            if exit_code ~= 0 then
                print("lazygit exited unsuccesfully with code " .. exit_code)
            end
            vim.api.nvim_win_close(float.win, true)
        end,
    })
    vim.api.nvim_create_autocmd("TermLeave", {
        buffer = float.buf,
        group = vim.api.nvim_create_augroup("lazygit-leave", { clear = true }),
        desc = "Close float when leaving terminal mode",
        callback = function()
            vim.api.nvim_win_close(float.win, true)
        end,
    })

    vim.cmd.startinsert()
end

vim.api.nvim_create_user_command("Lazygit", open_lazygit, {})
vim.api.nvim_set_keymap("n", "<leader>lg", ":Lazygit<CR>", { noremap = true, silent = true })
