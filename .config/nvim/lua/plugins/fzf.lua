---@module 'lazy'
---@type LazyPluginSpec | LazyPluginSpec[]
return {
	{
		"ibhagwan/fzf-lua",
		dependencies = { "echasnovski/mini.icons" },
		opts = {},
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
					require("fzf-lua").buffers({ resume = true, fzf_opts = { ["--query"] = "taco" } })
				end,
				desc = "Buffers",
			},
			{
				"<leader>fG",
				function()
					require("fzf-lua").git_status()
				end,
				desc = "Git Status",
			},
			{
				"<leader>fg",
				function()
					require("fzf-lua").git_files()
				end,
				desc = "Git Files",
			},
			{
				"<leader>fl",
				function()
					require("fzf-lua").lines()
				end,
				desc = "Lines across buffers",
			},

			{
				"<leader>/",
				function()
					require("fzf-lua").blines()
				end,
				desc = "Buffer Lines",
			},

			{
				"<leader>fh",
				function()
					require("fzf-lua").help_tags()
				end,
				desc = "Helptags",
			},
		},
		config = function(_, opts)
			require("fzf-lua").setup(opts)
			vim.opt.shell = "sh"
		end,
	},
}
