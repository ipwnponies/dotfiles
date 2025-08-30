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
	{
		"mbbill/undotree",
		cmd = "UndotreeToggle",
		config = function()
			vim.g.undotree_SetFocusWhenToggle = 1 -- Focus undotree window when toggled
			vim.g.undotree_ShortIndicators = 1 -- Use short relative time format
			vim.g.undotree_WindowLayout = 2 -- Set diff to horizontal wide split
		end,
	},
	{
		-- Search without moving the cursor. Keep offset position when searching with *
		"haya14busa/vim-asterisk",
		keys = {
			{ "*", "<Plug>(is-nohl)<Plug>(asterisk-z*)", mode = { "v", "n" } },
			{ "#", "<Plug>(is-nohl)<Plug>(asterisk-z#)", mode = { "v", "n" } },
			{ "g*", "<Plug>(is-nohl)<Plug>(asterisk-gz*)", mode = { "v", "n" } },
			{ "g#", "<Plug>(is-nohl)<Plug>(asterisk-gz#)", mode = { "v", "n" } },
		},
		config = function()
			vim.g["asterisk#keeppos"] = 1
		end,
	},
}
