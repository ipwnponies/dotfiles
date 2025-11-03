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

local function setup_lsp_keymaps(bufnr)
	local nmap = function(opts)
		local keys = opts.keys
		local func = opts.func
		local desc = opts.desc and ("LSP: " .. opts.desc) or nil
		local mode = opts.mode or "n"
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
end

---@type LazyPluginSpec | LazyPluginSpec[]
return {
	{
		"mason-org/mason-lspconfig.nvim",
		version = "^1.0.0",
		dependencies = {
			{
				"mason-org/mason.nvim",
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
		},
		ft = ft_array,
		opts = {
			ensure_installed = ensure_installed,
		},
		config = function(_, opts)
			local mason_lspconfig = require("mason-lspconfig")
			mason_lspconfig.setup(opts)

			local capabilities = require("lazy.core.config").plugins["blink.cmp"]
					and require("blink.cmp").get_lsp_capabilities({
						textDocument = { completion = { completionItem = { snippetSupport = false } } },
					})
				or require("cmp_nvim_lsp").default_capabilities()

			-- Change the Diagnostic symbols in the sign column (gutter)
			local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
			for type, icon in pairs(signs) do
				local hl = "DiagnosticSign" .. type
				vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
			end

			local function on_attach(_, bufnr)
				setup_lsp_keymaps(bufnr)

				vim.api.nvim_buf_create_user_command(bufnr, "Format", function(_)
					vim.lsp.buf.format()
				end, { desc = "Format current buffer with LSP" })
			end

			local lspconfig = require("lspconfig")
			mason_lspconfig.setup_handlers({
				function(server_name)
					vim.lsp.config(server_name, {
						capabilities = capabilities,
						on_attach = on_attach,
					})
					vim.lsp.enable(server_name)
				end,
				["pyright"] = function()
					vim.lsp.config("pyright", {
						capabilities = capabilities,
						on_attach = on_attach,
						root_dir = function(fname)
							if vim.g.project_pyright_root then
								local patterns = vim.g.project_pyright_root(fname)
								if patterns ~= nil then
									return lspconfig.util.root_pattern(unpack(patterns))(fname)
								end
							end
							return vim.lsp.config("pyright").document_config.default_config.root_dir(fname)
						end,
					})
					vim.lsp.enable("pyright")
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
		dependencies = {
			"mason-org/mason.nvim",
		},
		config = function()
			require("mason-tool-installer").setup({
				ensure_installed = {
					"stylua",
					"ruff",
					"fish-lsp",
				},
			})
		end,
	},
}
