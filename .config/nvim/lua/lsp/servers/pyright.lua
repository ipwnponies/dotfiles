---@param capabilities table
---@param on_attach fun(client: table, bufnr: integer)
return function(capabilities, on_attach)
	local lspconfig = require("lspconfig")

	vim.lsp.config("pyright", {
		capabilities = capabilities,
		on_attach = on_attach,
		root_dir = function(bufnr, on_dir)
			local fname = vim.api.nvim_buf_get_name(bufnr)
			local patterns
			local project_root = vim.g.project_pyright_root

			if project_root ~= nil then
				patterns = project_root(fname)
			end

			local root_dir_func = patterns and lspconfig.util.root_pattern(unpack(patterns))
				or require("lspconfig.configs.pyright").default_config.root_dir
			on_dir(root_dir_func(fname))
		end,
	})
	vim.lsp.enable("pyright")
end
