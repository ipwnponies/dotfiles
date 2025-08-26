---@type LazyPluginSpec | LazyPluginSpec[]
return {
	{
		"vim-airline/vim-airline",
		config = function()
			vim.g["airline#extensions#tabline#enabled"] = 1
		end,
	},
	{
		"sainnhe/sonokai",
		config = function()
			vim.g.sonokai_style = "shusia"
			vim.cmd([[colorscheme sonokai]])

			vim.api.nvim_set_hl(0, "Visual", { bg = "#535D7E" }) -- Visual mode: muted blue-gray bg for subtle but visible selection
			vim.api.nvim_set_hl(0, "Search", { bg = "#53575c" }) -- Search: muted green-gray to differentiate from Visual, still low contrast
		end,
	},
}
