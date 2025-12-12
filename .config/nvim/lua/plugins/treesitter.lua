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
		end,
	},
}
