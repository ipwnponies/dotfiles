-- LazyVim UI layer — gated behind vim.g.lv.ui = true.
-- Replaces: indent-blankline.nvim (via snacks.indent), basic cmdline/messages.
---@type LazyPluginSpec[]
return {
	-- Keymap popup with helix preset
	{
		"folke/which-key.nvim",
		enabled = lv_on("ui"),
		event = "VeryLazy",
		opts = {
			preset = "helix",
			spec = {
				{ "<leader>f", group = "Find" },
				{ "<leader>g", group = "Git" },
				{ "<leader>x", group = "Diagnostics" },
				{ "<leader>c", group = "Code" },
				{ "<leader>l", group = "Lazygit" },
			},
		},
	},

	-- Enhanced UI for messages, cmdline, and popupmenu
	{
		"folke/noice.nvim",
		enabled = lv_on("ui"),
		event = "VeryLazy",
		dependencies = { "MunifTanjim/nui.nvim" },
		opts = {
			lsp = {
				override = {
					["vim.lsp.util.convert_input_to_markdown_lines"] = true,
					["vim.lsp.util.stylize_markdown"] = true,
					["cmp.entry.get_documentation"] = true,
				},
			},
			routes = {
				{
					filter = {
						event = "msg_show",
						any = {
							{ find = "%d+L, %d+B" },
							{ find = "; after #%d+" },
							{ find = "; before #%d+" },
						},
					},
					view = "mini",
				},
			},
			presets = {
				bottom_search = true,
				command_palette = true,
				long_message_to_split = true,
				inc_rename = true,
			},
		},
	},

	-- Highlight and navigate TODO/HACK/FIX/NOTE/PERF comments
	{
		"folke/todo-comments.nvim",
		enabled = lv_on("ui"),
		cmd = { "TodoTrouble", "TodoTelescope" },
		event = { "BufReadPost", "BufNewFile" },
		opts = {},
		keys = {
			{ "<leader>ft", "<cmd>TodoTelescope<cr>", desc = "Find Todos" },
		},
	},

	-- Snacks: indent + notifier modules only (other domains may add more)
	{
		"folke/snacks.nvim",
		enabled = lv_on("ui"),
		optional = true,
		opts = {
			indent = { enabled = true },
			notifier = { enabled = true },
		},
	},
}
