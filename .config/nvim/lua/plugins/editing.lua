---@type LazyPluginSpec | LazyPluginSpec[]
return {
	{
		-- Split or join parameters
		"AndrewRadev/splitjoin.vim",
		keys = { "gS", "gJ" },
		config = function()
			vim.g.splitjoin_python_brackets_on_separate_lines = 1
			vim.g.splitjoin_trailing_comma = 1
		end,
	},
	{
		"AndrewRadev/sideways.vim",
		keys = {
			{ "<leader><c-h>", "<cmd>SidewaysLeft<cr>", mode = "n", silent = true },
			{ "<leader><c-l>", "<cmd>SidewaysRight<cr>", mode = "n", silent = true },
		},
	},
}
