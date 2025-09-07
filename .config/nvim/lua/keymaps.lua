-- Must be set early, so that plugin mappings map to it
vim.g.mapleader = " "

-- Switch buffers quickly with <TAB>
vim.api.nvim_set_keymap("n", "<TAB>", "<Cmd>bnext<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<S-TAB>", "<Cmd>bprevious<CR>", { noremap = true, silent = true })

vim.keymap.set("i", "jk", "<esc>", { silent = true }) -- Exit insert mode by typing 'jk'
vim.keymap.set("i", "<c-l>", "<c-g>u<esc>1z=`]a<c-g>u", { silent = true }) -- Fix last spelling error and return to insert mode
