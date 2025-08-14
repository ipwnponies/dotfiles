-- Autocmds
local autocmd = vim.api.nvim_create_autocmd

-- SQL files use expandtab
vim.api.nvim_create_autocmd("FileType", {
	pattern = "sql",
	callback = function()
		vim.opt_local.expandtab = true
	end,
})

-- Git commit settings
vim.api.nvim_create_autocmd("FileType", {
	pattern = "gitcommit",
	callback = function()
		vim.opt_local.spell = true
		vim.opt_local.textwidth = 72
		vim.opt_local.cursorline = false
	end,
})
-- Open quickfix window after quickfix commands
autocmd("QuickFixCmdPost", {
	pattern = "[^l]*",
	callback = function()
		vim.cmd("cwindow")
	end,
})

-- Open location window after location commands
autocmd("QuickFixCmdPost", {
	pattern = "l*",
	callback = function()
		vim.cmd("lwindow")
	end,
})

-- Set JSON filetype for avsc files
autocmd({ "BufRead", "BufNewFile" }, {
	pattern = "*.avsc",
	callback = function()
		vim.bo.filetype = "json"
	end,
})

-- Disable line numbers in terminal buffers
autocmd("TermOpen", {
	pattern = "*",
	callback = function()
		vim.wo.number = false
	end,
})

-- Set htmlcheetah filetype for tmpl files
autocmd({ "BufRead", "BufNewFile" }, {
	pattern = "*.tmpl",
	callback = function()
		vim.bo.filetype = "htmlcheetah"
	end,
})
