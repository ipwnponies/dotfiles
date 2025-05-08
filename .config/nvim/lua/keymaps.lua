-- Switch buffers quickly with <TAB>
vim.api.nvim_set_keymap('n', '<TAB>', '<Cmd>bnext<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<S-TAB>', '<Cmd>bprevious<CR>', { noremap = true, silent = true })
