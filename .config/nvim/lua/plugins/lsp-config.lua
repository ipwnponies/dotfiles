return {
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"RRethy/vim-illuminate",
			{ "antosha417/nvim-lsp-file-operations", config = true },
			{ "folke/neodev.nvim",                   opts = {} }, -- deprecated for lazydev
		},
		config = function()
			-- import lspconfig plugin
			local lspconfig = require("lspconfig")

			-- import mason_lspconfig plugin
			local mason_lspconfig = require("mason-lspconfig")

			-- import cmp-nvim-lsp plugin
			local cmp_nvim_lsp = require("cmp_nvim_lsp")

			local mason_lspconfig_on_attach = function(client, bufnr)
				local illuminate = require("illuminate")
				illuminate.on_attach(client)

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
				nmap({ keys = "[D", func = vim.diagnostic.goto_prev, desc = "Go to previous [d]iagnostic" })
				nmap({ keys = "]D", func = vim.diagnostic.goto_next, desc = "Go to next [d]diagnostic" })

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

				vim.api.nvim_buf_create_user_command(bufnr, "HopPythonParamsBye", function(_)
					local hop = require("hop")
					local regex = [[\v(def\s+\w+\s*\(.*)@<=\s*(\zs[^,)]+,?\ze).*\)]]
					local jump_regex = require("hop.jump_regex")
					local taco = jump_regex.regex_by_case_searching(regex, false, hop.opts)
					hop.hint_with_regex(taco, hop.opts)
				end, { desc = "Hop python" })

				nmap({
					keys = "]d",
					func = function()
						require("illuminate").next_reference({ wrap = true })
					end,
					desc = "Next Reference",
				})
				nmap({
					keys = "[d",
					func = function()
						require("illuminate").next_reference({ reverse = true, wrap = true })
					end,
					desc = "Previous Reference",
				})
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
			})

			lspconfig.fish_lsp.setup({
				on_attach = mason_lspconfig_on_attach,
			})
		end,
	},
	{
		"gfanto/fzf-lsp.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		event = "LspAttach",
		config = function()
			local function executeLua(action)
				local fzf_lsp_action = {
					Definition = true,
					References = true,
					Declaration = true,
					TypeDefinition = true,
					Implementation = true,
				}

				if fzf_lsp_action[action] then
					vim.cmd(action)
				else
					local ok, _ = pcall(vim.lsp.buf[action])
					if not ok then
						vim.api.nvim_err_writeln("Invalid LSP action: " .. action)
					end
				end
			end

			function LspAction()
				local actions = {
					"Definitio",
					"References",
					"Declaration",
					"TypeDefinition",
					"Implementation",
					"hover",
					"signature_help",
					"code_action",
					"formatting",
					"execute_command",
					"workspace_symbol",
					"document_symbol",
					"rename",
				}
				vim.fn["fzf#run"](vim.fn["fzf#wrap"]({
					source = actions,
					sink = executeLua,
				}))
			end

			vim.api.nvim_buf_create_user_command(0, "LspAction", LspAction, {})
			vim.keymap.set("n", "gl", LspAction, { noremap = true, silent = true })
		end,
	},
}
