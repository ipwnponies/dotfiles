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

-- Diff and folds
vim.opt.foldmethod = "syntax" -- Use syntax-based folding
vim.opt.foldenable = false -- Disable folding by default
vim.opt.diffopt:append("vertical") -- Show diffs in vertical splits
vim.opt.diffopt:append("context:2") -- Show 2 lines of context around diffs

-- Completion
vim.opt.wildignorecase = true -- Ignore case when completing file names and directories
vim.opt.completeopt = { "menuone", "popup" } -- Show menu even for one match, use popup menu for completion

-- Temp file directories
local undodir = vim.fn.expand("~/.cache/vim/undo")
local directory = vim.fn.expand("~/.cache/vim/swp")

local function ensure_dir(dir)
	if not vim.loop.fs_stat(dir) == nil then
		vim.loop.fs_mkdir(dir, 448) -- 448 = 0700 in decimal
	end
end

ensure_dir(undodir)
ensure_dir(directory)

vim.opt.undodir = undodir --     directory for persistent undo files
vim.opt.directory = directory -- directory for swap files
vim.opt.undofile = true --       enable persistent undo across sessions

-- Local overrides
vim.opt.exrc = true -- allow per-project .nvim.lua or .exrc config (potential security risk)
