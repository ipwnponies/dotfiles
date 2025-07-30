---@module 'lazy'
---@type LazyPluginSpec | LazyPluginSpec[]
return {
	{
		"ipwnponies/vim-agriculture",
		dependencies = { "junegunn/fzf.vim" },
		cmd = { "RgRaw" },
		keys = {
			{ "<leader>*", "<Plug>RgRawVisualSelection", mode = "v" },
			{ "<leader>*", "<Plug>RgRawWordUnderCursor", mode = "n" },
		},
	},
}
