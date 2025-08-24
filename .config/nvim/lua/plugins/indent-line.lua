---@type LazyPluginSpec | LazyPluginSpec[]
return {
	{
		"Yggdroot/indentLine",
		config = function()
			-- Set conceal cursor to always show
			-- Need to set indentline plugin because it rudely clobbers concealcursor for reasons
			vim.opt.concealcursor = "incv"
			vim.g.indentLine_concealcursor = vim.o.concealcursor
		end,
	},
}
