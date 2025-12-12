---@type LazyPluginSpec[]
return {
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		lazy = false, -- plugin documented to not support lazy loading
		build = ":TSUpdate",
		event = { "BufReadPost", "BufNewFile" },
		cmd = { "TSUpdateSync", "TSInstall" },
		dependencies = {
			-- tree-sitter-cli is required, managed by devbox
		},
		config = function()
			local languages = {
				"bash",
				"comment",
				"diff",
				"gitignore",
				"html",
				"javascript",
				"jsdoc",
				"json",
				"jsonc",
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
			}

			local treesitter = require("nvim-treesitter")
			local install_parsers = function()
				local missing = vim.tbl_filter(function(lang)
					return not vim.list_contains(treesitter.get_installed(), lang)
				end, languages)

				if #missing > 0 then
					treesitter.install(missing)
				end
			end

			install_parsers()

			local group = vim.api.nvim_create_augroup("treesitter-core", { clear = true })
			vim.api.nvim_create_autocmd("FileType", {
				pattern = languages,
				group = group,
				-- enable treesitter-powered highlight/folds/indent only for the selected buffers
				callback = function(args)
					vim.treesitter.start(args.buf)

					vim.api.nvim_set_option_value("foldmethod", "expr", { scope = "local", win = 0 })
					vim.api.nvim_set_option_value(
						"foldexpr",
						"v:lua.vim.treesitter.foldexpr()",
						{ scope = "local", win = 0 }
					)
					vim.api.nvim_set_option_value(
						"indentexpr",
						"v:lua.require'nvim-treesitter'.indentexpr()",
						{ buf = 0 }
					)
				end,
			})
		end,
	},
	{
		"nvim-treesitter/nvim-treesitter-textobjects",
		branch = "main",
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
			local select = require("nvim-treesitter-textobjects.move")

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
			local move = require("nvim-treesitter-textobjects.select")

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
			vim.keymap.set({ "n", "x", "o" }, "[b", function() -- Sorry, ]c is taken by gitgutter to move by 'changes'
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
		end,
	},
}
