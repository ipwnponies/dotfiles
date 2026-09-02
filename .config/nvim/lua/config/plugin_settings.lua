-- Undotree, set vim options so files maintain undofile even when plugin is lazy loaded
local cache_home = vim.env.XDG_CACHE_HOME
if cache_home == nil or cache_home == "" then
	cache_home = vim.fn.expand("~/.cache")
end

local undodir = cache_home .. "/vim/undo"
local directory = cache_home .. "/vim/swp"

local function ensure_dir(dir)
	if not vim.uv.fs_stat(dir) == nil then
		vim.uv.fs_mkdir(dir, 448) -- 448 = 0700 in decimal
	end
end

ensure_dir(undodir)
ensure_dir(directory)

vim.opt.undodir = undodir --     directory for persistent undo files
vim.opt.directory = directory -- directory for swap files
vim.opt.undofile = true --       enable persistent undo across sessions

return { taco = "bar" }
