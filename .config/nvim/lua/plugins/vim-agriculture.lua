---@type LazyPluginSpec | LazyPluginSpec[]
return {
	{
		"ipwnponies/vim-agriculture",
		dependencies = {
			"junegunn/fzf.vim",
			dependencies = {
				"junegunn/fzf",
			},
			config = function()
				vim.g.fzf_preview_window = { "up:60%:+{2}/4", "ctrl-/" }
			end,
		},
		cmd = { "RgRaw" },
		keys = {
			{ "<leader>*", "<Plug>RgRawVisualSelection", mode = "v" },
			{ "<leader>*", "<Plug>RgRawWordUnderCursor", mode = "n" },
		},
	},
}
