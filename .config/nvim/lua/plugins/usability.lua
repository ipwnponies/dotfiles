---@type LazyPluginSpec | LazyPluginSpec[]
return {
	{
		-- Show the contents of registers
		"junegunn/vim-peekaboo",
		-- Annoyingly, we need to switch buffers to get this to lazy load correctly
		-- Must have something that hooks upon BufRead events
		keys = { '"', "@", { "<C-r>", mode = "i" } },
		config = function()
			vim.g.peekaboo_window = "botright 30new"
			vim.g.peekaboo_delay = 300
		end,
	},
	{
		"mbbill/undotree",
		cmd = "UndotreeToggle",
		config = function()
			local cache_home = vim.fn.getenv("XDG_CACHE_HOME")
			if cache_home == vim.NIL or cache_home == "" then
				cache_home = vim.fn.expand("~/.cache")
			end

			local undodir = cache_home .. "/vim/undo"
			local directory = cache_home .. "/vim/swp"

			local function ensure_dir(dir)
				if not vim.loop.fs_stat(dir) == nil then
					vim.loop.fs_mkdir(dir, 448) -- 448 = 0700 in decimal
				end
			end

			ensure_dir(undodir)
			ensure_dir(directory)

			vim.opt.undodir = undodir --     directory for persistent undo files
			vim.opt.directory = directory -- directory for swap files
			vim.opt.undofile = true --       enable persistent undo across sessions

			vim.g.undotree_SetFocusWhenToggle = 1 -- Focus undotree window when toggled
			vim.g.undotree_ShortIndicators = 1 -- Use short relative time format
			vim.g.undotree_WindowLayout = 2 -- Set diff to horizontal wide split
		end,
	},
}
