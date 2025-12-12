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
}
