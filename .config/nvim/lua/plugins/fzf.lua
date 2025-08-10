---@module 'lazy'
---@type LazyPluginSpec | LazyPluginSpec[]
return {
	{
		"ibhagwan/fzf-lua",
		dependencies = { "echasnovski/mini.icons" },
		opts = {
			keymap = {
				fzf = {
					["ctrl-a"] = "toggle-all",
					["home"] = "first",
					["end"] = "last",
				},
			},
		},
		keys = {
			{
				"<leader>ff",
				function()
					require("fzf-lua.cmd").run_command("builtin")
				end,
				desc = "FzfLua",
			},
			{
				"<leader>f",
				function()
					require("fzf-lua.cmd").run_command("resume")
				end,
				desc = "Resume",
			},
			{
				"<leader>fb",
				function()
					require("fzf-lua").buffers({ resume = true })
				end,
				desc = "Buffers",
			},
			{
				"<leader>fG",
				function()
					require("fzf-lua").git_status({ resume = true })
				end,
				desc = "Git Status",
			},
			{
				"<leader>fg",
				function()
					require("fzf-lua").git_files({ resume = true })
				end,
				desc = "Git Files",
			},
			{
				"<leader>fl",
				function()
					require("fzf-lua").lines({ resume = true })
				end,
				desc = "Lines across buffers",
			},

			{
				"<leader>/",
				function()
					require("fzf-lua").blines({ resume = true })
				end,
				desc = "Buffer Lines",
			},

			{
				"<leader>fh",
				function()
					require("fzf-lua").help_tags({ resume = true })
				end,
				desc = "Helptags",
			},
			{
				"<leader>fj",
				function()
					require("fzf-lua").jumps({ resume = true })
				end,
				desc = "Jumps",
			},
		},
		config = function(_, opts)
			require("fzf-lua").setup(opts)
			vim.opt.shell = "sh"
			-- Disable FZF_DEFAULT_OPTS to avoid conflicts with fzf-lua
			vim.env.FZF_DEFAULT_OPTS = ""
		end,
	},
}
