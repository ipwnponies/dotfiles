local lsp_filetypes = {
	bashls = { "sh", "bash" },
	cssls = { "css", "scss", "less" },
	dockerls = { "dockerfile" },
	EXTERNAL_LSP = { "fish", "terraform" },
	gopls = { "go" },
	html = { "html" },
	jsonls = { "json" },
	lua_ls = { "lua" },
	pyright = { "python" },
	rust_analyzer = { "rust" },
	ts_ls = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
	vimls = { "vim" },
	yamlls = { "yaml", "yml" },
}

-- For lazy.nvim:
local ft = {}
local ensure_installed = {}

for lsp, types in pairs(lsp_filetypes) do
	if lsp ~= "EXTERNAL_LSP" then
		table.insert(ensure_installed, lsp)
	end
	for _, t in ipairs(types) do
		ft[t] = true
	end
end

local ft_array = {}
for t, _ in pairs(ft) do
	table.insert(ft_array, t)
end

---@type LazyPluginSpec | LazyPluginSpec[]
return {
	{
		"mason-org/mason-lspconfig.nvim",
		version = "^1.0.0",
		dependencies = {
			{
				"williamboman/mason.nvim",
				version = "^1.0.0",
				---@type MasonSettings
				opts = {
					ui = {
						icons = {
							package_installed = "✓",
							package_pending = "➜",
							package_uninstalled = "✗",
						},
					},
				},
			},
			{ "j-hui/fidget.nvim", tag = "v1.6.1" },
			"neovim/nvim-lspconfig",
			{ "saghen/blink.cmp" },
			{
				"folke/lazydev.nvim",
				ft = { "lua" },
				---@class (partial) opts : lazydev.Config
				---@type opts
				opts = {
					library = {
						-- See the configuration section for more details
						-- Load luvit types when the `vim.uv` word is found
						{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
					},
				},
			},
		},
		ft = ft_array,
		opts = {
			ensure_installed = ensure_installed,
		},
		config = function(_, opts)
			local mason_lspconfig = require("mason-lspconfig")
			mason_lspconfig.setup(opts)

			local capabilities = require("blink.cmp").get_lsp_capabilities({
				textDocument = { completion = { completionItem = { snippetSupport = false } } },
			})

			-- Change the Diagnostic symbols in the sign column (gutter)
			local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
			for type, icon in pairs(signs) do
				local hl = "DiagnosticSign" .. type
				vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
			end

			local function on_attach(_, bufnr)
				require("lsp.keymaps").setup(bufnr)

				vim.api.nvim_buf_create_user_command(bufnr, "Format", function(_)
					vim.lsp.buf.format()
				end, { desc = "Format current buffer with LSP" })
			end

			mason_lspconfig.setup_handlers({
				function(server_name)
					vim.lsp.config(server_name, {
						capabilities = capabilities,
						on_attach = on_attach,
					})
					vim.lsp.enable(server_name)
				end,
				["ts_ls"] = function()
					require("lsp.servers.ts_ls")(capabilities, on_attach)
				end,
				["pyright"] = function()
					require("lsp.servers.pyright")(capabilities, on_attach)
				end,
			})

			-- Fish LSP is not managed by mason, it's external
			vim.lsp.config("fish_lsp", {
				on_attach = on_attach,
				capabilities = capabilities,
			})
			vim.lsp.enable("fish_lsp")
		end,
	},
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		dependencies = { "williamboman/mason.nvim" },
		opts = {
			ensure_installed = {
				"fish_lsp",
				"ruff",
				"shellcheck",
				"stylua",
			},
		},
	},
}
