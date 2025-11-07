---@type LazyPluginSpec | LazyPluginSpec[]
return {
	-- TODO: replace ale with lua native replacement. treesitter?
	{
		"w0rp/ale",
		config = function()
			vim.g.ale_echo_msg_format = "[%linter%] %code: %%s"
			vim.g.ale_lint_on_insert_leave = 1
			vim.g.ale_lint_on_text_changed = "normal"
			vim.g.ale_fix_on_save = 1

			local js_linters = { "eslint", "prettier" }

			vim.g.ale_fixers = {
				javascript = js_linters,
				javascriptreact = js_linters,
				typescriptreact = js_linters,
				markdown = { "prettier" },
				python = { "black", "isort", "ruff", "ruff_format" },
				terraform = { "terraform" },
				lua = { "stylua" },
				["*"] = { "remove_trailing_lines", "trim_whitespace" },
			}

			vim.g.ale_linters = {
				python = {},
			}
			vim.g.ale_linters_ignore = {
				javascript = { "tsserver" },
				lua = { "lua_language_server" },
				["*"] = { "remove_trailing_lines", "trim_whitespace" },
			}
		end,
	},
	{
		"mfussenegger/nvim-lint",
		event = { "BufReadPost", "BufNewFile" },
		config = function()
			local lint = require("lint")

			lint.linters_by_ft = {
				sh = { "shellcheck" },
				bash = { "shellcheck" },
				terraform = { "tflint" },
			}

			local function has_linters(ft)
				local linters = lint.linters_by_ft[ft]
				if type(linters) == "table" then
					return #linters > 0
				end
				return false
			end

			local group = vim.api.nvim_create_augroup("UserLintAutoCmds", { clear = true })
			vim.api.nvim_create_autocmd({ "BufWritePost", "InsertLeave" }, {
				group = group,
				callback = function(args)
					local ft = vim.bo[args.buf].filetype
					if ft ~= "" and has_linters(ft) then
						lint.try_lint(nil, { bufnr = args.buf })
					end
				end,
			})
		end,
	},
}
