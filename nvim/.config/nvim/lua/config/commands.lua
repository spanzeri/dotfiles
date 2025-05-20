--
-- Highlight yanked text
--
vim.api.nvim_create_autocmd("TextYankPost", {
    callback = function() vim.highlight.on_yank() end,
    group = vim.api.nvim_create_augroup("CustomYankHighlightGroup", { clear = true }),
    pattern = "*",
    desc = "Highlight yanked text",
})

--
-- Trailing whitespaces
--

local trailing_ws_group = vim.api.nvim_create_augroup("TrailingWhitespaceGroup", { clear = true })

local TrailingWS = {
    match_group = "TrailingWhitespace",
}

TrailingWS.enable_hl = function(self)
    local function is_normal_buffer()
        return vim.bo.buftype == "" and vim.bo.filetype ~= "help"
    end

    if not TrailingWS.is_enabled() or vim.fn.mode() ~= "n" then
        TrailingWS.disable_hl()
        return
    end

    if not is_normal_buffer() or TrailingWS.get_match_id() ~= nil then
        return
    end

    -- priority one so that it's higher than search but lower than anything else
    vim.fn.matchadd(TrailingWS.match_group, [[\s\+$]], 1)
    vim.fn.matchadd(TrailingWS.match_group, [[\v(^\s*\n){1}\zs(^\s*\n)*%$\n]], 1)
end

TrailingWS.disable_hl = function()
    while true do
        local match_id = TrailingWS.get_match_id()
        if not match_id or match_id <= 0 then
            break
        end
        vim.fn.matchdelete(match_id)
    end
end

TrailingWS.is_enabled = function()
    return not vim.g.ignore_trailing_whitespaces and not vim.b.ignore_trailing_whitespaces
end

TrailingWS.get_match_id = function()
    for _, match in ipairs(vim.fn.getmatches()) do
        if match.group == TrailingWS.match_group then
            return match.id
        end
    end
end

TrailingWS.trim_whitespaces_eol = function()
    for index, line in ipairs(vim.fn.getline(1, "$")) do
        vim.fn.setline(index, vim.fn.substitute(line, [[\s\+$]], "", ""))
    end
end

TrailingWS.trim_whitespaces_eof = function()
    local lines = vim.api.nvim_buf_get_lines(0, 1, -1, false)
    local last_empty = #lines
    for index = #lines, 1, -1 do
        if not lines[index]:match([[^%s*$]]) then
            break
        end
        last_empty = index
    end

    if last_empty < #lines then
        vim.api.nvim_buf_set_lines(0, last_empty, #lines, false, {})
    end
end

TrailingWS.trim_whitespaces = function()
    TrailingWS.trim_whitespaces_eol()
    TrailingWS.trim_whitespaces_eof()
end

vim.api.nvim_set_hl(0, TrailingWS.match_group, { bg = "#560D0F", ctermbg = "Red", default = true })

vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter", "InsertLeave", "TermClose" }, {
    callback = function() TrailingWS.enable_hl() end,
    group = trailing_ws_group,
    pattern = "*",
    desc = "Enable trailing whitespace highlights",
})

vim.api.nvim_create_autocmd({ "WinLeave", "BufLeave", "InsertEnter", "TermOpen" }, {
    callback = function() TrailingWS.disable_hl() end,
    group = trailing_ws_group,
    pattern = "*",
    desc = "Disable trailing whitespace highlights",
})

vim.api.nvim_create_user_command("TrimWhitespaces", TrailingWS.trim_whitespaces, {})
vim.api.nvim_create_user_command("TrimWhitespacesEOL", TrailingWS.trim_whitespaces_eol, {})
vim.api.nvim_create_user_command("TrimWhitespacesEOF", TrailingWS.trim_whitespaces_eof, {})

--
-- Auto-reload files on change
--

local file_reload_group = vim.api.nvim_create_augroup("AutoReloadFiles", { clear = true })

vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
    callback = function()
        if vim.loop.fs_stat(vim.fn.expand("%")) then
            vim.cmd.checktime()
        end
    end,
    group = file_reload_group,
    pattern = "*",
    desc = "Check for file modifications outside neovim",
})

vim.api.nvim_create_autocmd("FileChangedShellPost", {
    callback = function()
        vim.notify("File changed on disk, reloading", vim.log.levels.INFO, {})
    end,
    group = file_reload_group,
    pattern = "*",
    desc = "Notify user when a file has changed and gets reloaded",
})

--
-- Create scratch buffers
--

vim.api.nvim_create_user_command("ScratchNew", function()
    local bufnr = vim.api.nvim_create_buf(true, true)
    if bufnr == 0 then
        vim.api.nvim_notify("Error creating scratch buffer", vim.log.levels.ERROR, {})
    end

    local scratch_names = {}
    local prefix = "*scratch"
    local prefix_len = #prefix
    for _, obuf in ipairs(vim.api.nvim_list_bufs()) do
        local bufname = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(obuf), ":~:.")
        if string.sub(bufname, 1, prefix_len) == prefix then
            scratch_names[bufname] = true
        end
    end

    local scratch_name = "*scratch*"
    if scratch_names[scratch_name] then
        local found_name = false
        local scratch_num = 1
        while not found_name do
            scratch_num = scratch_num + 1
            scratch_name = "*scratch_" .. scratch_num .. "*"
            found_name = not scratch_names[scratch_name]
        end
    end

    vim.api.nvim_buf_set_name(bufnr, scratch_name)
    vim.api.nvim_win_set_buf(0, bufnr)
end , {})

--
-- Better terminal and help drawing
--

vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter", "BufWinEnter", "InsertEnter" }, {
    callback = function()
        if vim.bo.buftype      == "terminal"
            or vim.bo.buftype  == "prompt"
            or vim.bo.filetype == "help"
            or vim.bo.buftype  == "quickfix"
            or vim.bo.filetype == "man"
            or vim.bo.filetype:find("dapui_", 1, true) == 1
        then
            vim.opt.number = false
            vim.opt.list = false
        else
            vim.opt.number = true
            vim.opt.list = true
        end
    end,
    group = vim.api.nvim_create_augroup("TerminalAndHelp", { clear = true }),
    desc = "Remove line number and whitechars from terminal and help buffers",
})

-- ==============================================================================
--  Mini plugin to evaluate lua code in the current buffer.
-- ==============================================================================

--- Lua execution
---@param code string Lua code to execute
local execute_lua_code = function(code)
    local print_output = {}
    local capture_print = function(...)
        local items = {}
        for _, item in ipairs { ... } do
            table.insert(items, vim.inspect(item))
        end
        local output = table.concat(items, " ")
        local out_lines = vim.split(output, "\n")
        for _, line in ipairs(out_lines) do
            table.insert(print_output, line)
        end
    end

    vim.notify("Executing lua code: "..code, vim.log.levels.INFO, { title = "Lua execution" })

    local load_ok, fun = pcall(loadstring, code)
    if not load_ok then
        vim.notify("Failed to load code", vim.log.levels.ERROR, { title = "Lua load error" })
        return nil, nil
    elseif type(fun) ~= "function" then
        vim.notify("Invalid lua code", vim.log.levels.ERROR, { title = "Lua execution error" })
        return nil, nil
    end

    local old_print = print
    print = capture_print
    local ok, result = pcall(fun)
    print = old_print
    if not ok then
        vim.notify(result, vim.log.levels.ERROR, { title = "Lua execution error" })
        return nil, nil
    end

    return result, print_output
end

--- Evaluate lua code in the current buffer, from line l1 to l2
local eval_lua_inline = function()
    local mode = vim.fn.mode()
    local code, out_line
    vim.notify("Mode: " .. mode, vim.log.levels.INFO, { title = "LuaEval" })
    if mode == "v" or mode == 'V' then
        local visualp = vim.fn.getpos "v"
        local sr, sc = visualp[2], visualp[3]
        local cursorp = vim.fn.getpos "."
        local er, ec = cursorp[2], cursorp[3]

        if sr > er or (sr == er and sc > ec) then
            sr, er = er, sr
            sc, ec = ec, sc
        end

        vim.notify("Sr: " .. sr .. " Sc: " .. sc .. " Er: " .. er .. " Ec: " .. ec, vim.log.levels.INFO, { title = "LuaEval" })
        local code_lines = vim.api.nvim_buf_get_text(0, sr, sc, er, ec, {})
        code = table.concat(code_lines, "\n")
        out_line = er
    else
        code = "return " .. vim.api.nvim_get_current_line()
        out_line = vim.fn.line "."
    end

    local result, output = execute_lua_code(code)
    if result then
        local out_string = vim.inspect(result)
        local out_lines = vim.split(out_string, "\n")
        for i, line in ipairs(out_lines) do
            local prefix = i == 1 and "=> " or "   "
            out_lines[i] = prefix .. line
        end
        if output and #output > 0 then
            table.insert(out_lines, "--- Output ---")
            for _, line in ipairs(output) do
                table.insert(out_lines, line)
            end
            table.insert(out_lines, "--------------")
        end
        vim.api.nvim_buf_set_lines(0, out_line, out_line, false, out_lines)
    end
end

vim.api.nvim_create_user_command("LuaEval", eval_lua_inline, { range = true })
vim.keymap.set({ "n", "v" }, "<leader>xe", eval_lua_inline, { desc = "e[x]ecute lua [e]xpression" })


