---@type LazyPluginSpec | LazyPluginSpec[]
-- LazyVim picker domain: snacks.picker replaces fzf-lua + telescope.
-- Active when vim.g.lv.picker = true; gated off otherwise (see lua/config/migration.lua).
return {
	{
		"folke/snacks.nvim",
		priority = 1000,
		lazy = false,
		enabled = lv_on("picker"),
		---@type snacks.Config
		opts = {
			picker = { enabled = true },
			-- Other snacks modules are intentionally omitted here; they will be
			-- configured by their respective domain migration specs.
		},
		keys = {
			{
				"<leader>ff",
				function()
					Snacks.picker.files()
				end,
				desc = "Find Files",
			},
			{
				"<leader>f",
				function()
					Snacks.picker.resume()
				end,
				desc = "Resume",
			},
			{
				"<leader>fb",
				function()
					Snacks.picker.buffers()
				end,
				desc = "Buffers",
			},
			{
				"<leader>fG",
				function()
					Snacks.picker.git_status()
				end,
				desc = "Git Status",
			},
			{
				"<leader>fg",
				function()
					Snacks.picker.git_files()
				end,
				desc = "Git Files",
			},
			{
				-- Cross-buffer: snacks grep is the equivalent of fzf-lua lines()
				"<leader>fl",
				function()
					Snacks.picker.grep()
				end,
				desc = "Lines across buffers",
			},
			{
				-- Current buffer: snacks lines() is the equivalent of fzf-lua blines()
				"<leader>/",
				function()
					Snacks.picker.lines()
				end,
				desc = "Buffer Lines",
			},
			{
				"<leader>fh",
				function()
					Snacks.picker.help()
				end,
				desc = "Helptags",
			},
			{
				"<leader>fj",
				function()
					Snacks.picker.jumps()
				end,
				desc = "Jumps",
			},
			{
				"<leader>fc",
				function()
					Snacks.picker.commands()
				end,
				desc = "Commands",
			},
			{
				"<leader>fC",
				function()
					Snacks.picker.command_history()
				end,
				desc = "Command History",
			},
		},
	},
}
