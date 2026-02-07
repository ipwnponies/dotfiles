---@type LazyPluginSpec | LazyPluginSpec[]
return {
	{
		"Yggdroot/indentLine",
		init = function()
			vim.g.indentLine_fileTypeExclude = { "markdown", "json" }
		end,
		config = function()
			-- Set conceal cursor to always show
			-- Need to set indentline plugin because it rudely clobbers concealcursor for reasons
			vim.opt.concealcursor = "c" -- Disable conceal during insert and visual mode; only in normal and command-line modes
			vim.g.indentLine_concealcursor = vim.o.concealcursor
		end,
	},
}
