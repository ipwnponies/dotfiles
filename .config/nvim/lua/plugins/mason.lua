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
		ensure_installed[#ensure_installed + 1] = lsp
	end
	for _, t in ipairs(types) do
		ft[t] = true
	end
end

-- Convert ft table to array
local ft_array = {}
for t, _ in pairs(ft) do
	table.insert(ft_array, t)
end

---@type LazyPluginSpec | LazyPluginSpec[]
return {
	"mason-org/mason-lspconfig.nvim",
	version = "^1.0.0",
	dependencies = {
		{
			"mason-org/mason.nvim",
			version = "^1.0.0",
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
		"hrsh7th/cmp-nvim-lsp",
		"hrsh7th/cmp-nvim-lsp-document-symbol",
		"hrsh7th/cmp-nvim-lsp-signature-help",
	},
	ft = ft_array,
	opts = {
		ensure_installed = ensure_installed,
	},
	config = function(_, opts)
		-- import lspconfig plugin
		local lspconfig = require("lspconfig")

		-- import mason_lspconfig plugin
		local mason_lspconfig = require("mason-lspconfig")
		mason_lspconfig.setup(opts)

		-- import cmp-nvim-lsp plugin
		local cmp_nvim_lsp = require("cmp_nvim_lsp")

		local mason_lspconfig_on_attach = function(client, bufnr)
			local nmap = function(opts)
				opts = opts or {}
				local keys = opts.keys
				local func = opts.func
				local desc = opts.desc
				local mode = opts.mode or "n"
				if desc then
					desc = "LSP: " .. desc
				end

				vim.keymap.set(mode, keys, func, { buffer = bufnr, desc = desc })
			end
			nmap({ keys = "<leader>rn", func = vim.lsp.buf.rename, desc = "[R]e[n]ame" })
			nmap({
				keys = "<leader>ca",
				func = vim.lsp.buf.code_action,
				desc = "[C]ode [A]ction",
				mode = { "n", "v" },
			})
			nmap({ keys = "gd", func = vim.lsp.buf.definition, desc = "[G]oto [D]efinition" })
			nmap({ keys = "gD", func = vim.lsp.buf.declaration, desc = "[G]oto [D]eclaration" })
			nmap({
				keys = "gr",
				func = function()
					vim.cmd("References")
				end,
				desc = "[G]oto [R]eferences",
			})
			nmap({ keys = "gR", func = "<cmd>Telescope lsp_references<CR>", desc = "Show LSP [R]eferences" })
			nmap({ keys = "gI", func = vim.lsp.buf.implementation, desc = "[G]oto [I]mplementation" })
			nmap({
				keys = "gt",
				func = "<cmd>Telescope lsp_type_definitions<CR>",
				desc = "[G]oto [T]ype Definitions",
			})

			nmap({
				keys = "<leader>D",
				func = "<cmd>Telescope diagnostics bufnr=0<CR>",
				desc = "Show Buffer [D]iagnostics",
			})
			nmap({ keys = "<leader>d", func = vim.diagnostic.open_float, desc = "Show Line [D]iagnostics" })

			nmap({
				keys = "<leader>ds",
				func = require("telescope.builtin").lsp_document_symbols,
				desc = "[D]ocument [S]ymbols",
			})
			nmap({
				keys = "<leader>ws",
				func = require("telescope.builtin").lsp_dynamic_workspace_symbols,
				desc = "[W]orkspace [S]ymbols",
			})
			nmap({ keys = "K", func = vim.lsp.buf.hover, desc = "Hover Documentation" })
			nmap({ keys = "<leader>k", func = vim.lsp.buf.signature_help, desc = "Signature Documentation" })

			vim.api.nvim_buf_create_user_command(bufnr, "Format", function(_)
				vim.lsp.buf.format()
			end, { desc = "Format current buffer with LSP" })
		end

		-- used to enable autocompletion (assign to every lsp server config)
		local capabilities = cmp_nvim_lsp.default_capabilities()

		-- Change the Diagnostic symbols in the sign column (gutter)
		local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
		for type, icon in pairs(signs) do
			local hl = "DiagnosticSign" .. type
			vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
		end

		mason_lspconfig.setup_handlers({
			-- default handler for installed servers
			function(server_name)
				lspconfig[server_name].setup({
					capabilities = capabilities,
					on_attach = mason_lspconfig_on_attach,
				})
			end,
			["pyright"] = function()
				lspconfig.pyright.setup({
					capabilities = capabilities,
					on_attach = mason_lspconfig_on_attach,
					root_dir = function(fname)
						---@type fun(fname: string): table|nil
						vim.g.project_pyright_root = vim.g.project_pyright_root

						if vim.g.project_pyright_root then
							local patterns = vim.g.project_pyright_root(fname)
							if patterns ~= nil then
								return lspconfig.util.root_pattern(unpack(patterns))(fname)
							end
						end

						return lspconfig.pyright.document_config.default_config.root_dir(fname)
					end,
				})
			end,
		})

		-- Fish LSP is not managed by mason, it's external
		lspconfig.fish_lsp.setup({
			on_attach = mason_lspconfig_on_attach,
			cmd = { "fish-lsp" }, -- I guess this makes it non-interactive. Yay
		})
	end,
}
