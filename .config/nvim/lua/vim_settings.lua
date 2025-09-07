vim.opt.updatetime = 250
vim.opt.signcolumn = "yes"
vim.opt.spell = true

-- Set conceal cursor to always show
vim.opt.concealcursor = "incv"

-- Abbreviations:
vim.cmd("iabbrev todo: TODO(TICKET):")
vim.cmd("cabbrev w!! w !sudo tee >/dev/null %") -- Command-line: allows saving file with sudo using 'w!!'

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

-- Visuals
vim.opt.visualbell = true -- Enable visual bell instead of beeping
vim.opt.cursorline = true -- Highlight the current line
vim.opt.number = true -- Show absolute line numbers
vim.opt.scrolloff = 3 -- Keep 3 lines visible above/below cursor
vim.opt.showmatch = true -- Briefly jump to matching bracket
vim.opt.showbreak = ">>" -- String to show at start of wrapped lines
vim.opt.linebreak = true -- Break lines at word boundaries
vim.opt.breakindent = true -- Indent wrapped lines to match parent line
-- Configure break indent options:
-- - Show showbreak character at far left
-- - Shift by 4
-- - Keep hanging indents at least 60 columns wide
vim.opt.breakindentopt = { "sbr", "shift:4", "min:60" }

-- Layout
vim.opt.textwidth = 120 -- Set maximum text width to 120 characters
vim.opt.splitbelow = true -- New horizontal splits open below
vim.opt.splitright = true -- New vertical splits open to the right

-- Local overrides
vim.opt.exrc = true -- allow per-project .nvim.lua or .exrc config (potential security risk)

-- Mouse handling
vim.opt.mouse = "a" -- Enable mouse support in all modes (normal, visual, insert, command-line)
