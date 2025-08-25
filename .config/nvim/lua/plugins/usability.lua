---@type LazyPluginSpec | LazyPluginSpec[]
return {
	{
		-- Show the contents of registers
		"junegunn/vim-peekaboo",
		-- Annoyingly, we need to switch buffers to get this to lazy load correctly
		-- Must have something that hooks upon BufRead events
		keys = { '"', "@", { "<C-r>", mode = "i" } },
		config = function()
			vim.g.peekaboo_window = "botright 30new"
			vim.g.peekaboo_delay = 300
		end,
	},
}
