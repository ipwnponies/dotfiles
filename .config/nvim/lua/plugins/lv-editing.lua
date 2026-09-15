---@type LazyPluginSpec | LazyPluginSpec[]
-- LazyVim editing domain: mini.ai/surround/pairs + ts-comments replace
-- vim-indent-object, vim-sandwich, vim-endwise, vim-commentary when
-- vim.g.lv.editing = true.
--
-- Key differences from legacy plugins:
--   vim-commentary (`gcc`/`gc`)       → ts-comments.nvim (`gcc`/`gc`, treesitter-aware)
--   vim-sandwich (`sa`/`sd`/`sr`)     → mini.surround (`gsa`/`gsd`/`gsr`/`gsf`/`gsF`)
--   vim-endwise (auto `end`/`endif`)  → mini.pairs (bracket auto-close, partial overlap)
--   vim-indent-object (`ii`/`ai`)     → mini.ai (`f`/`c`/`a`/`q` + indent via `i`)
return {
	{
		"echasnovski/mini.ai",
		enabled = lv_on("editing"),
		event = "VeryLazy",
		opts = {
			-- n_lines: max lines to search around cursor for text objects.
			n_lines = 500,
		},
	},
	{
		"echasnovski/mini.surround",
		enabled = lv_on("editing"),
		event = "VeryLazy",
		opts = {
			-- Remap to `gs*` prefix to avoid clashing with `s` (flash) in motion domain.
			mappings = {
				add            = "gsa", -- Add surrounding in Normal and Visual modes
				delete         = "gsd", -- Delete surrounding
				find           = "gsf", -- Find surrounding (to the right)
				find_left      = "gsF", -- Find surrounding (to the left)
				highlight      = "gsh", -- Highlight surrounding
				replace        = "gsr", -- Replace surrounding
				update_n_lines = "gsn", -- Update `n_lines`
			},
		},
	},
	{
		"echasnovski/mini.pairs",
		enabled = lv_on("editing"),
		event = "VeryLazy",
		opts = {},
	},
	{
		"folke/ts-comments.nvim",
		enabled = lv_on("editing"),
		event = "VeryLazy",
		opts = {},
	},
}
