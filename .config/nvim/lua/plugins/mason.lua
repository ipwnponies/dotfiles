---@module 'lazy'
---@type LazyPluginSpec | LazyPluginSpec[]
return {
	"williamboman/mason.nvim",
	dependencies = {
		"williamboman/mason-lspconfig.nvim",
		{ "mason-org/mason.nvim", version = "^1.0.0" },
		{ "mason-org/mason-lspconfig.nvim", version = "^1.0.0" },
	},
	config = function()
		-- import mason
		local mason = require("mason")

		-- import mason-lspconfig
		local mason_lspconfig = require("mason-lspconfig")

		-- enable mason and configure icons
		mason.setup({
			ui = {
				icons = {
					package_installed = "✓",
					package_pending = "➜",
					package_uninstalled = "✗",
				},
			},
		})

		mason_lspconfig.setup({
			-- list of servers for mason to install
			ensure_installed = {
				"bashls",
				"cssls",
				"dockerls",
				"gopls",
				"html",
				"jsonls",
				"lua_ls",
				"pyright",
				-- 'ruff',
				"rust_analyzer",
				-- 'stylua' ,
				"ts_ls",
				"vimls",
				"yamlls",
			},
		})
	end,
}
