return {
	"stevearc/conform.nvim",
	event = "BufWritePre",
	opts = {
		formatters = {
			prettier_jsonc = {
				inherit = "prettier",
				prepend_args = { "--parser", "jsonc", "--trailing-comma", "all" },
			},
		},
		formatters_by_ft = {
			bash = { "shfmt" },
			javascript = { "prettier" },
			jsonc = { "prettier_jsonc" },
			lua = { "stylua" },
			markdown = { "prettier" },
			python = { "ruff_format" },
			sh = { "shfmt" },
			typescript = { "prettier" },
		},
		format_on_save = function()
			return { timeout_ms = 500, lsp_format = "fallback" }
		end,
	},
	async = true,
}
