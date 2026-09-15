---@type LazyPluginSpec[]
return {
	{
		"nvim-treesitter/nvim-treesitter",
		enabled = lv_on("treesitter"),
		build = ":TSUpdate",
		event = { "BufReadPost", "BufNewFile" },
		main = "nvim-treesitter.configs",
		opts = {
			ensure_installed = {
				"bash",
				"c",
				"comment",
				"cpp",
				"css",
				"diff",
				"gitignore",
				"html",
				"javascript",
				"jsdoc",
				"json",
				"lua",
				"luadoc",
				"luap",
				"markdown",
				"markdown_inline",
				"printf",
				"python",
				"query",
				"regex",
				"toml",
				"tsx",
				"typescript",
				"vim",
				"vimdoc",
				"xml",
				"yaml",
			},
			highlight = { enable = true },
			indent = { enable = true },
			incremental_selection = {
				enable = true,
				keymaps = {
					init_selection = "<C-space>",
					node_incremental = "<C-space>",
					scope_incremental = false,
					node_decremental = "<bs>",
				},
			},
		},
	},
	{
		"nvim-treesitter/nvim-treesitter-textobjects",
		enabled = lv_on("treesitter"),
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		---@type TSTextObjects.UserConfig
		opts = {
			-- restore the previous select/move behavior with the new standalone API
			select = {
				lookahead = true,
				include_surrounding_whitespace = true,
			},
		},
		config = function(_, opts)
			require("nvim-treesitter-textobjects").setup(opts)

			-- Select by syntax
			local select = require("nvim-treesitter-textobjects.select")

			vim.keymap.set({ "x", "o" }, "af", function()
				select.select_textobject("@function.outer", "textobjects")
			end, { desc = "Treesitter select outer function" })
			vim.keymap.set({ "x", "o" }, "if", function()
				select.select_textobject("@function.inner", "textobjects")
			end, { desc = "Treesitter select inner function" })
			vim.keymap.set({ "x", "o" }, "ac", function()
				select.select_textobject("@class.outer", "textobjects")
			end, { desc = "Treesitter select outer class" })
			vim.keymap.set({ "x", "o" }, "ic", function()
				select.select_textobject("@class.inner", "textobjects")
			end, { desc = "Treesitter select inner class" })
			vim.keymap.set({ "x", "o" }, "aa", function()
				select.select_textobject("@parameter.outer", "textobjects")
			end, { desc = "Treesitter select outer parameter" })
			vim.keymap.set({ "x", "o" }, "ia", function()
				select.select_textobject("@parameter.inner", "textobjects")
			end, { desc = "Treesitter select inner parameter" })

			-- Motions
			local move = require("nvim-treesitter-textobjects.move")

			vim.keymap.set({ "n", "x", "o" }, "[m", function()
				move.goto_previous_start("@function.outer", "textobjects")
			end, { desc = "Treesitter previous function start" })
			vim.keymap.set({ "n", "x", "o" }, "]m", function()
				move.goto_next_start("@function.outer", "textobjects")
			end, { desc = "Treesitter next function start" })
			vim.keymap.set({ "n", "x", "o" }, "[M", function()
				move.goto_previous_end("@function.outer", "textobjects")
			end, { desc = "Treesitter previous function end" })
			vim.keymap.set({ "n", "x", "o" }, "]M", function()
				move.goto_next_end("@function.outer", "textobjects")
			end, { desc = "Treesitter next function end" })
			vim.keymap.set({ "n", "x", "o" }, "[b", function()
				move.goto_previous_start("@class.outer", "textobjects")
			end, { desc = "Treesitter previous class start" })
			vim.keymap.set({ "n", "x", "o" }, "]b", function()
				move.goto_next_start("@class.outer", "textobjects")
			end, { desc = "Treesitter next class start" })
			vim.keymap.set({ "n", "x", "o" }, "[B", function()
				move.goto_previous_end("@class.outer", "textobjects")
			end, { desc = "Treesitter previous class end" })
			vim.keymap.set({ "n", "x", "o" }, "]B", function()
				move.goto_next_end("@class.outer", "textobjects")
			end, { desc = "Treesitter next class end" })

			-- swap parameters around
			local swap = require("nvim-treesitter-textobjects.swap")

			vim.keymap.set("n", "<leader><c-l>", function()
				swap.swap_next("@parameter.inner")
			end, { desc = "Treesitter swap parameter with next" })
			vim.keymap.set("n", "<leader><c-h>", function()
				swap.swap_previous("@parameter.inner")
			end, { desc = "Treesitter swap parameter with previous" })
		end,
	},
	{
		"windwp/nvim-ts-autotag",
		enabled = lv_on("treesitter"),
		ft = {
			"html",
			"javascript",
			"typescript",
			"javascriptreact",
			"typescriptreact",
			"svelte",
			"vue",
			"tsx",
			"jsx",
			"xml",
			"markdown",
		},
		opts = {},
	},
}
