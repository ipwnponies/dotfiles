---@type LazyPluginSpec | LazyPluginSpec[]
return {
	{
		"tpope/vim-fugitive",
		enabled = lv_off("git"),
		keys = {
			{ "<leader>gs", "<cmd>Git<CR>", mode = "n", desc = "Git status" },
			{ "<leader>gb", "<cmd>Git blame<CR>", mode = { "n", "v" }, desc = "Git blame" },
		},
		cmd = { "Gdiffsplit", "Gdifftool" },
		config = function()
			-- Abbreviate :Gdiffsplit to always compare with upstream (e.g., origin/branch)
			vim.keymap.set("ca", "Gdiffsplit", "Gdiffsplit @{u}...")

			-- Create :Gdifftool command to get file list changed since upstream
			vim.api.nvim_create_user_command("Gdifftool", "Git difftool --name-only @{u}...", {})
		end,
	},
	{
		"ruanyl/vim-gh-line",
		enabled = lv_off("git"),
		keys = {
			{ "<leader>gB", "<Plug>(gh-line-blame)", mode = { "n", "v" }, desc = "GitHub line blame" },
			{ "<leader>gh", mode = { "n", "v" }, desc = "GitHub line" },
		},
	},
	{ "junegunn/gv.vim", enabled = lv_off("git"), dependencies = { "tpope/vim-fugitive" }, cmd = { "GV" } },
	{ "airblade/vim-gitgutter", enabled = lv_off("git") },
}
