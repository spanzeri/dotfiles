local hl_comments_group = vim.api.nvim_create_augroup("HLCommentsGroup", { clear = true })
local regexes = {}
local uv = vim.uv or vim.loop
local buffer_state = {}
local RANGE_PADDING = 1
local hl_ns = vim.api.nvim_create_namespace("hl-comments")

local function compile_regexes(cfg)
    regexes = {}

    for _, group in ipairs(cfg.groups) do
        local altk = table.concat(group.keywords, "|")
        for _, p in ipairs(cfg.patterns) do
            local pattern = [[\v]] .. p
            local re = vim.regex(pattern:gsub("<KEYWORDS>", altk))
            local zs, ze = re:match_str("")
            if zs and ze and ze <= zs then
                error("hl-comments: zero-width patterns are not allowed: " .. p)
            end
            table.insert(regexes, {
                category = group.category,
                regex = re,
            })
        end
    end
end

local function get_comment_ranges(bufnr, start_row, end_row)
    local ok_parser, parser = pcall(vim.treesitter.get_parser, bufnr)
    if not ok_parser or not parser then
        return {}
    end

    local lang = parser:lang()
    local ok_q, query = pcall(vim.treesitter.query.parse, lang, "(comment) @c")
    if not ok_q or not query then
        return {}
    end

    local tree = parser:parse()[1]
    if not tree then
        return {}
    end

    local root = tree:root()
    local ranges = {}
    for _, node in query:iter_captures(root, bufnr, start_row, end_row + 1) do
        local srow, scol, erow, ecol = node:range()
        table.insert(ranges, { srow = srow, scol = scol, erow = erow, ecol = ecol })
    end
    return ranges
end

-- This runs on a range and queries tree-sitter for all the comments
local function update_range(bufnr, start_row, end_row, cfg)
    if not vim.api.nvim_buf_is_valid(bufnr) then
        return
    end

    if vim.api.nvim_get_option_value("buftype", { buf = bufnr }) ~= "" then
        return
    end

    vim.api.nvim_buf_clear_namespace(bufnr, hl_ns, start_row, end_row + 1)

    local comment_ranges = get_comment_ranges(bufnr, start_row, end_row)
    for _, range in ipairs(comment_ranges) do
        local lines = vim.api.nvim_buf_get_text(bufnr, range.srow, range.scol, range.erow, range.ecol, {})
        for line_idx, line in ipairs(lines) do
            local row = range.srow + (line_idx - 1)
            local base_col = (line_idx == 1) and range.scol or 0
            for _, spec in ipairs(regexes) do
                local hs = cfg.highlights[spec.category]
                local hl_group = hs and hs[1]
                if hl_group then
                    local at = 0
                    while true do
                        local chunk = line:sub(at + 1)
                        if chunk == "" then
                            break
                        end
                        local s, e = spec.regex:match_str(chunk)
                        if not s then
                            break
                        end
                        s = s + at
                        e = e + at
                        if e <= s then
                            break
                        end

                        vim.api.nvim_buf_set_extmark(bufnr, hl_ns, row, base_col + s, {
                            end_row = row,
                            end_col = base_col + e,
                            hl_group = hl_group,
                            priority = cfg.priority,
                        })

                        at = e
                    end
                end
            end
        end
    end
end

local function merge_ranges(ranges)
    if #ranges <= 1 then
        return ranges
    end

    table.sort(ranges, function(a, b)
        return a.srow < b.srow
    end)

    local merged = {}
    local cur = { srow = ranges[1].srow, erow = ranges[1].erow }

    for i = 2, #ranges do
        local nxt = ranges[i]
        if nxt.srow <= (cur.erow + 1) then
            cur.erow = math.max(cur.erow, nxt.erow)
        else
            table.insert(merged, cur)
            cur = { srow = nxt.srow, erow = nxt.erow }
        end
    end

    table.insert(merged, cur)
    return merged
end

local function expand_and_clamp_ranges(bufnr, ranges)
    local line_count = vim.api.nvim_buf_line_count(bufnr)
    if line_count <= 0 then
        return {}
    end

    local out = {}
    for _, range in ipairs(ranges) do
        local srow = math.max(0, range.srow - RANGE_PADDING)
        local erow = math.min(line_count - 1, range.erow + RANGE_PADDING)
        if srow <= erow then
            table.insert(out, { srow = srow, erow = erow })
        end
    end

    return out
end

local function ensure_state(bufnr)
    local st = buffer_state[bufnr]
    if st then
        return st
    end

    st = {
        pending = {},
        timer = uv.new_timer(),
        running = false,
        generation = 0,
        attached = false,
    }
    buffer_state[bufnr] = st
    return st
end

local function timer_is_alive(timer)
    return timer and not timer:is_closing()
end

local function cleanup_buffer(bufnr)
    local st = buffer_state[bufnr]
    if not st then
        return
    end

    if timer_is_alive(st.timer) then
        st.timer:stop()
        st.timer:close()
    end

    buffer_state[bufnr] = nil
end

local function process_ranges_async(bufnr, ranges, generation, cfg, on_done)
    local i = 1
    local budget_ms = 4

    local function step()
        if not vim.api.nvim_buf_is_valid(bufnr) then
            on_done()
            return
        end

        local st = buffer_state[bufnr]
        if not st or st.generation ~= generation then
            on_done()
            return
        end

        local tick_start = uv.hrtime()
        while i <= #ranges do
            local range = ranges[i]
            update_range(bufnr, range.srow, range.erow, cfg)
            i = i + 1

            local elapsed_ms = (uv.hrtime() - tick_start) / 1000000
            if elapsed_ms >= budget_ms then
                vim.schedule(step)
                return
            end
        end

        on_done()
    end

    vim.schedule(step)
end

local function flush_pending(bufnr, cfg)
    local st = buffer_state[bufnr]
    if not st or st.running or #st.pending == 0 then
        return
    end

    local merged = merge_ranges(st.pending)
    st.pending = {}
    local ranges = expand_and_clamp_ranges(bufnr, merged)
    if #ranges == 0 then
        return
    end

    st.running = true
    st.generation = st.generation + 1
    local generation = st.generation

    process_ranges_async(bufnr, ranges, generation, cfg, function()
        local latest = buffer_state[bufnr]
        if not latest then
            return
        end

        latest.running = false
        if #latest.pending > 0 and timer_is_alive(latest.timer) then
            latest.timer:stop()
            latest.timer:start(cfg.debounce_ms, 0, vim.schedule_wrap(function()
                flush_pending(bufnr, cfg)
            end))
        end
    end)
end

local function queue_range(bufnr, start_row, end_row, cfg)
    if not vim.api.nvim_buf_is_valid(bufnr) then
        return
    end

    local st = ensure_state(bufnr)
    local line_count = vim.api.nvim_buf_line_count(bufnr)
    if line_count <= 0 then
        return
    end

    start_row = math.max(0, start_row)
    end_row = math.max(start_row, end_row)
    end_row = math.min(end_row, line_count - 1)

    table.insert(st.pending, { srow = start_row, erow = end_row })

    if timer_is_alive(st.timer) then
        st.timer:stop()
        st.timer:start(cfg.debounce_ms, 0, vim.schedule_wrap(function()
            flush_pending(bufnr, cfg)
        end))
    end
end

local function queue_full_buffer(bufnr, cfg)
    if not vim.api.nvim_buf_is_valid(bufnr) then
        return
    end

    local last_line = vim.api.nvim_buf_line_count(bufnr) - 1
    if last_line < 0 then
        return
    end

    queue_range(bufnr, 0, last_line, cfg)
end

local function attach_buffer(bufnr, cfg)
    if not vim.api.nvim_buf_is_valid(bufnr) then
        return
    end

    if vim.api.nvim_get_option_value("buftype", { buf = bufnr }) ~= "" then
        return
    end

    local st = ensure_state(bufnr)
    if st.attached then
        return
    end

    st.attached = true
    vim.api.nvim_buf_attach(bufnr, false, {
        on_lines = function(_, b, _, firstline, _, new_lastline, _)
            local end_row = math.max(firstline, new_lastline - 1)
            queue_range(b, firstline, end_row, cfg)
        end,
        on_detach = function(_, b)
            cleanup_buffer(b)
        end,
    })

    queue_full_buffer(bufnr, cfg)
end

local function merge(a, b)
    return vim.tbl_deep_extend("force", a, b or {})
end

local default_config = {
    groups = {
        {
            category = "todo",
            keywords = { "TODO", "ToDo", "FIXME", "FixMe", "OPTIM", "Optim" },
        },
        {
            category = "warn",
            keywords = { "HACK", "Hack", "WARNING", "Warning", "WARN", "Warn", "IMPORTANT", "Important" },
        },
        {
            category = "note",
            keywords = { "NOTE", "Note" },
        },
    },
    highlights = {
        ["todo"] = { "DiagnosticError" },
        ["warn"] = { "DiagnosticWarn" },
        ["note"] = { "DiagnosticNote" },
    },
    patterns = {
        [[\zs(<KEYWORDS>)\ze\(.*\):]],
        [[\zs\@(<KEYWORDS>)\ze(\(.*\))?:?]],
    },
    debounce_ms = 40,
    priority = 200,
}

return {
    setup = function(opt)
        local cfg = merge(vim.deepcopy(default_config), opt or {})
        compile_regexes(cfg)

        vim.api.nvim_create_autocmd({ "BufWinEnter", "BufReadPost", "BufNewFile" }, {
            group = hl_comments_group,
            callback = function(ev)
                attach_buffer(ev.buf, cfg)
            end,
        })

        vim.api.nvim_create_autocmd({ "BufUnload", "BufWipeout" }, {
            group = hl_comments_group,
            callback = function(ev)
                cleanup_buffer(ev.buf)
            end,
        })

        vim.api.nvim_create_user_command("HLCommentsUpdate", function()
            local bufnr = vim.api.nvim_get_current_buf()
            attach_buffer(bufnr, cfg)
            queue_full_buffer(bufnr, cfg)
            flush_pending(bufnr, cfg)
        end, {})
    end,
}
