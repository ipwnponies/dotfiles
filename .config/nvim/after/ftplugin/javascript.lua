-- Mapping
vim.api.nvim_buf_set_keymap(0, "ia", "fr", "() => {<CR>}", {})
vim.api.nvim_buf_set_keymap(0, "ia", "debugger", "debugger; // eslint-disable-line", {})
