---@type LazyPluginSpec | LazyPluginSpec[]
return {
	{
		"ibhagwan/fzf-lua",
		dependencies = { "echasnovski/mini.icons" },
		---@type fzf-lua.config.Defaults  | table<any, any>
		opts = {
			keymap = {
				fzf = {
					["alt-a"] = "toggle-all",
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
					require("fzf-lua").buffers()
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
					require("fzf-lua").lines({ resume = true })
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
			vim.env.FZF_DEFAULT_OPTS = ""
		end,
	},
}
