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
		end,
	},
}
