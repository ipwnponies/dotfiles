---@module 'lazy'
---@type LazyPluginSpec | LazyPluginSpec[]
return {
	"kdheepak/lazygit.nvim",
	cmd = {
		"LazyGit",
		"LazyGitConfig",
		"LazyGitCurrentFile",
		"LazyGitFilter",
		"LazyGitFilterCurrentFile",
	},
	dependencies = {
		"nvim-lua/plenary.nvim",
	},
	keys = {
		{ "<leader>ll", "<cmd>LazyGitCurrentFile<cr>", desc = "LazyGit Current File" },
		{ "<leader>lc", "<cmd>LazyGitFilterCurrentFile<cr>", desc = "LazyGit Filter Current File" },
	},
}
