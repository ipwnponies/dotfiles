-- LazyVim git domain: gitsigns (hunk signs/staging/blame) + snacks (lazygit UI + gitbrowse).
-- Active when vim.g.lv.git = true. See lua/config/migration.lua.
---@type LazyPluginSpec | LazyPluginSpec[]
return {
	{
		"lewis6991/gitsigns.nvim",
		enabled = lv_on("git"),
		event = { "BufReadPre", "BufNewFile" },
		opts = {
			signs = {
				add          = { text = "+" },
				change       = { text = "~" },
				delete       = { text = "_" },
				topdelete    = { text = "‾" },
				changedelete = { text = "~" },
			},
		},
		keys = {
			-- Hunk navigation
			{ "]h", function() require("gitsigns").next_hunk() end, desc = "Next hunk" },
			{ "[h", function() require("gitsigns").prev_hunk() end, desc = "Prev hunk" },
			-- Hunk staging
			{ "<leader>hs", function() require("gitsigns").stage_hunk() end, mode = { "n", "v" }, desc = "Stage hunk" },
			{ "<leader>hu", function() require("gitsigns").undo_stage_hunk() end, desc = "Undo stage hunk" },
			-- Inline blame (replaces <leader>gb fugitive blame)
			{ "<leader>gb", function() require("gitsigns").blame_line({ full = true }) end, desc = "Git blame line" },
		},
	},
	{
		"folke/snacks.nvim",
		enabled = lv_on("git"),
		optional = true,
		opts = {
			-- Only enable the git-domain modules here; other domains manage their own snacks modules.
			lazygit   = { enabled = true },
			gitbrowse = { enabled = true },
		},
		keys = {
			-- lazygit UI (replaces <leader>gs fugitive status and lazygit.nvim)
			{ "<leader>gs", function() Snacks.lazygit() end,           desc = "Lazygit" },
			{ "<leader>ll", function() Snacks.lazygit.log_file() end,  desc = "LazyGit log (current file)" },
			{ "<leader>lc", function() Snacks.lazygit.log_file() end,  desc = "LazyGit log filter (current file)" },
			-- gitbrowse (replaces vim-gh-line)
			{ "<leader>gB", function() Snacks.gitbrowse() end,         mode = { "n", "v" }, desc = "Git browse (blame)" },
			{ "<leader>gh", function() Snacks.gitbrowse() end,         mode = { "n", "v" }, desc = "Git browse (open line)" },
		},
	},
}
