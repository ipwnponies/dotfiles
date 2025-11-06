-- python uses four-space indents
vim.opt_local.tabstop = 4
vim.opt_local.softtabstop = 0
vim.opt_local.shiftwidth = 0
vim.opt_local.expandtab = true

vim.api.nvim_buf_set_keymap(0, "ia", "pudb", [[breakpoint() # noqa]], {})

-- Add -> None to all pytest test cases
vim.api.nvim_create_user_command("TestReturnNone", [[%s/\vdef test_.*(None)@<!\zs\ze:$/ -> None/]], {})
