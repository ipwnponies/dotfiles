vim.opt.updatetime = 250
vim.opt.signcolumn = "yes"

-- Format Option:
vim.opt.formatoptions:append("b") -- Break at blank. No autowrapping if line is >textwidth before insert or no blank
vim.opt.formatoptions:append("j") -- Remove comment leader when joining lines
vim.opt.formatoptions:append("c") -- Insert comment leader when wrapping lines
vim.opt.formatoptions:append("r") -- Insert comment leader in insert mode when <CR>
vim.opt.formatoptions:append("q") -- Allow gq for comments
