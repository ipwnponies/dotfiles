---@param path string?
---@return string?
local function is_valid_python(path)
	if path and path ~= "" and vim.fn.executable(path) == 1 then
		return path
	end
	return nil
end

-- Cheap checks only (env var, filesystem stats) — safe to run synchronously.
---@param root_dir string
---@return string?
local function resolve_sync(root_dir)
	local ok, project_python = pcall(function()
		local override = vim.g.project_pyright_python
		return override and override(root_dir) or nil
	end)
	local python_path = (ok and is_valid_python(project_python)) or nil

	if python_path == nil and vim.env.VIRTUAL_ENV then
		python_path = is_valid_python(vim.env.VIRTUAL_ENV .. "/bin/python")
	end

	if python_path == nil then
		python_path = is_valid_python(root_dir .. "/.venv/bin/python")
	end

	return python_path
end

---@param cmd string[]
---@param root_dir string
---@param on_done fun(stdout: string?)
local function run_async(cmd, root_dir, on_done)
	local ok = pcall(vim.system, cmd, { cwd = root_dir, timeout = 2000 }, function(result)
		local stdout = result.code == 0 and vim.trim(result.stdout or "") or nil
		vim.schedule(function()
			on_done(stdout)
		end)
	end)
	if not ok then
		on_done(nil)
	end
end

-- Shells out to poetry/pyenv asynchronously so a slow or hung command
-- doesn't block the editor; calls on_done(python_path) exactly once.
---@param root_dir string
---@param on_done fun(python_path: string?)
local function resolve_async(root_dir, on_done)
	local function try_pyenv()
		if vim.fn.executable("pyenv") == 1 then
			-- pyenv shim on PATH is a dispatcher with no pyvenv.cfg/site-packages
			-- beside it; use `pyenv which`'s resolved interpreter instead.
			run_async({ "pyenv", "which", "python" }, root_dir, function(resolved)
				on_done(is_valid_python(resolved))
			end)
		else
			on_done(nil)
		end
	end

	if vim.fn.filereadable(root_dir .. "/pyproject.toml") == 1 and vim.fn.executable("poetry") == 1 then
		run_async({ "poetry", "env", "info", "--path" }, root_dir, function(venv_dir)
			local python_path = venv_dir and venv_dir ~= "" and is_valid_python(venv_dir .. "/bin/python")
			if python_path then
				on_done(python_path)
			else
				try_pyenv()
			end
		end)
	else
		try_pyenv()
	end
end

---@param capabilities table
---@param on_attach fun(client: table, bufnr: integer)
return function(capabilities, on_attach)
	local lspconfig = require("lspconfig")
	-- Resolved pythonPath per root_dir, `false` meaning "resolved to nothing".
	-- Not invalidated once set, so e.g. running `poetry install` after an
	-- initial miss needs a Neovim restart to be picked up — use
	-- :LspPyrightSetPythonPath (from lspconfig) to override a running client.
	---@type table<string, string|false>
	local python_path_cache = {}

	vim.lsp.config("pyright", {
		capabilities = capabilities,
		on_attach = on_attach,
		-- Non-nil so before_init below can mutate it in place; lspconfig's own
		-- pyright default also sets settings, but don't rely on that staying true.
		settings = { python = {} },
		root_dir = function(bufnr, on_dir)
			local fname = vim.api.nvim_buf_get_name(bufnr)
			local patterns
			local project_root = vim.g.project_pyright_root

			if project_root ~= nil then
				patterns = project_root(fname)
			end

			local root_dir_func = patterns and lspconfig.util.root_pattern(unpack(patterns))
				or require("lspconfig.configs.pyright").default_config.root_dir
			local root = root_dir_func(fname)

			if root == nil or python_path_cache[root] ~= nil then
				on_dir(root)
				return
			end

			local python_path = resolve_sync(root)
			if python_path then
				python_path_cache[root] = python_path
				on_dir(root)
				return
			end

			resolve_async(root, function(resolved)
				python_path_cache[root] = resolved or false
				on_dir(root)
			end)
		end,
		-- root_dir is resolved per buffer, so pythonPath must be read here
		-- (once per client, since config.root_dir is already resolved and
		-- python_path_cache is already populated by root_dir above) rather
		-- than passed statically to vim.lsp.config above.
		before_init = function(_, config)
			local python_path = config.root_dir and python_path_cache[config.root_dir]
			if python_path then
				-- Client.create() snapshots client.settings = config.settings by
				-- reference before before_init runs, so reassigning config.settings
				-- to a brand-new table (rather than mutating fields on it) would
				-- silently leave the client's own settings unset.
				config.settings = config.settings or {}
				config.settings.python = vim.tbl_deep_extend("force", config.settings.python or {}, {
					pythonPath = python_path,
				})
			end
		end,
	})
	vim.lsp.enable("pyright")
end
