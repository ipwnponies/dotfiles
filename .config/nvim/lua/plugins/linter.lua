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
			vim.g.ale_linters_ignore = {
				javascript = { "tsserver" },
				["*"] = { "remove_trailing_lines", "trim_whitespace" },
			}
		end,
	},
}
