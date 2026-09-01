local markers = { "tsconfig.json", "jsconfig.json", "package.json" }

local function is_within(path, base)
	return path == base or vim.startswith(path, base .. "/")
end

local function ts_root_for_file(fname)
	local cwd = vim.fs.normalize(vim.uv.cwd())
	local dir = vim.fs.normalize(vim.fs.dirname(fname))

	if not is_within(dir, cwd) then
		return nil
	end

	while dir do
		for _, marker in ipairs(markers) do
			if vim.uv.fs_stat(dir .. "/" .. marker) then
				return dir
			end
		end

		if dir == cwd then
			break
		end

		local parent = vim.fs.dirname(dir)
		if not parent or parent == dir then
			break
		end
		dir = parent
	end

	-- Keep standalone JS/TS files constrained to the current working directory.
	return cwd
end

---@param capabilities table
---@param on_attach fun(client: table, bufnr: integer)
return function(capabilities, on_attach)
	vim.lsp.config("ts_ls", {
		capabilities = capabilities,
		on_attach = on_attach,
		-- Never walk above cwd while resolving project root.
		root_dir = function(bufnr, on_dir)
			local fname = vim.api.nvim_buf_get_name(bufnr)
			on_dir(ts_root_for_file(fname))
		end,
		single_file_support = true,
		-- Keep tsserver memory bounded so startup/indexing spikes are less disruptive.
		init_options = {
			hostInfo = "neovim",
			maxTsServerMemory = 2048,
		},
	})
	vim.lsp.enable("ts_ls")
end
