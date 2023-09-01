--[[ Git plugin config ]]

vim.keymap.set('n', '<leader>gs', vim.cmd.Git, { silent = true, desc = '[g]it [s]tatus' })
vim.keymap.set('n', 'gh', '<cmd>diffget //2<CR>', { silent = true, desc = '[g]it diffget left [h]' })
vim.keymap.set('n', 'gl', '<cmd>diffget //3<CR>', { silent = true, desc = '[g]it diffget left [h]' })
