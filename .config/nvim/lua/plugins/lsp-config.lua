return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"hrsh7th/cmp-nvim-lsp",
		"RRethy/vim-illuminate",
		{ "antosha417/nvim-lsp-file-operations", config = true },
		{ "folke/neodev.nvim", opts = {} }, -- deprecated for lazydev
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
			nmap({ keys = "<leader>ca", func = vim.lsp.buf.code_action, desc = "[C]ode [A]ction", mode = { "n", "v" } })
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
			nmap({ keys = "gt", func = "<cmd>Telescope lsp_type_definitions<CR>", desc = "[G]oto [T]ype Definitions" })


			vim.api.nvim_buf_create_user_command(bufnr, "Format", function(_)
				vim.lsp.buf.format()
			end, { desc = "Format current buffer with LSP" })

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
	end,
}
