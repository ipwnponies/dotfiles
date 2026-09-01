local M = {}

function M.setup(bufnr)
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
			require("fzf_lsp").references_call()
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

return M
