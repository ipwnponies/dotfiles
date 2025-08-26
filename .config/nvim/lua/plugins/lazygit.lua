---@type LazyPluginSpec | LazyPluginSpec[]
return {
	"kdheepak/lazygit.nvim",
	commit = "b9eae3badab982e71abab96d3ee1d258f0c07961",
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
