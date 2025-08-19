vim.opt.updatetime = 250
vim.opt.signcolumn = "yes"

-- Format Option:
vim.opt.formatoptions:append("b") -- Break at blank. No autowrapping if line is >textwidth before insert or no blank
vim.opt.formatoptions:append("j") -- Remove comment leader when joining lines
vim.opt.formatoptions:append("c") -- Insert comment leader when wrapping lines
vim.opt.formatoptions:append("r") -- Insert comment leader in insert mode when <CR>
vim.opt.formatoptions:append("q") -- Allow gq for comments

-- Search and substitute
vim.opt.hlsearch = true --      Highlight all search matches
vim.opt.incsearch = true --     Show search matches as you type (incremental search)
vim.opt.ignorecase = true --    Searches ignore case by default
vim.opt.smartcase = true --     If search contains uppercase, make it case-sensitive
vim.opt.gdefault = true --      :substitute operates globally on each line by default
vim.opt.inccommand = "split" -- Show live preview of :substitute in a split window

-- Spaces, Tabs, and Indents

vim.opt.expandtab = true --  Use spaces instead of tabs
vim.opt.tabstop = 4 --       Tabs are 4 spaces
vim.opt.softtabstop = 0 --   When editing, 4 spaces are treated as tabs
vim.opt.shiftwidth = 0 --    Match tabstop for shift operation (>>)
vim.opt.autoindent = true -- Copy indent from current line when starting a new line
