-- Exit vim mode with jj
vim.keymap.set("i", "jj", [[<Esc>]])
vim.keymap.set("t", "jj", [[<C-\><C-n>]])

-- Exit terminal with esc+esc (it won't work in every terminal, tmux etc).
-- When it does not work, <C-\><C-n> can still be used
vim.keymap.set("t", "<Esc><Esc>", [[<C-\\><C-n>]])

-- Disable search highlight on escape pressed
vim.keymap.set("n", "<Esc>", [[<cmd>nohlsearch<CR>]])

-- Ctrl+Del and Ctrl+BS in insert mode
vim.keymap.set("i", "<C-del>", [[<C-o>dw]])
vim.keymap.set("i", "<C-BS>", [[<C-o>db]])

-- Move visual selection up and down
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- Better movement
vim.keymap.set("n", "k", [[v:count == 0? "gk" : "k"]], { expr = true, silent = true })
vim.keymap.set("n", "j", [[v:count == 0? "gj" : "j"]], { expr = true, silent = true })
vim.keymap.set("n", "<C-d>", [[<C-d>zz]])
vim.keymap.set("n", "<C-u>", [[<C-u>zz]])
vim.keymap.set("n", "n", [[nzz]])
vim.keymap.set("n", "N", [[Nzz]])

-- Diagnostic keymaps
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to previous [d]iagnistic message" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Go to next [d]iagnistic message" })
vim.keymap.set("n", "<leader>ef", vim.diagnostic.open_float, { desc = "Show diagnostic [f]loat" })
vim.keymap.set("n", "<leader>el", vim.diagnostic.setloclist, { desc = "Move diagnostics to [l]oclist" })
vim.keymap.set("n", "<leader>ee", vim.cmd.cc, { desc = "go to first [e]rror" })
vim.keymap.set("n", "<leader>en", vim.cmd.cn, { desc = "go to [e]rror [n]ext" })
vim.keymap.set("n", "<leader>ep", vim.cmd.cp, { desc = "go to [e]rror [p]rev" })
vim.keymap.set("n", "<leader>eo", vim.cmd.copen, { desc = "[e]rrors [o]pen" })
vim.keymap.set("n", "<leader>ec", vim.cmd.cclose, { desc = "[e]rrors [c]lose" })

local toggle_errors = function()
    local ewinid = vim.fn.getqflist({ winid = 0 }).winid
    if ewinid == 0 then
        vim.fn.copen()
    else
        vim.fn.cclose()
    end
end

vim.keymap.set("n", "<leader>et", toggle_errors, { desc = "[e]rrors [t]oggle" })

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

-- Save and source lua
vim.keymap.set("n", "<leader>xx", [[<cmd>w | so<CR>]], { desc = "Write and source file" })

-- Compilation

local set_mkprg = function()
    local prev_mp = vim.o.makeprg
    local mp = vim.fn.input({
        prompt = "Make command: ",
        default = prev_mp,
        completion = "compiler"
    })
    if mp ~= nil and mp ~= "" then
        vim.o.makeprg = mp
    end
end

vim.keymap.set("n", "<leader>ms", set_mkprg, { desc = "[m]ake [s]et" })
vim.keymap.set("n", "<leader>mm", [[:silent! wa | make! | cw 30<CR>]], { desc = "[m]ake [m]ake" })
