-- init.lua
require("settings") -- basic options
require("keymaps") -- key mappings
require("config.lazy") -- plugin manager and plugins
require("binary-editing") -- binary file editing utilities
require("autocmds")
require("vim_settings") -- converted settings from init.vim
require("colours") -- converted settings from init.vim

-- Load host-specific configurations
local init_local = vim.fn.fnamemodify(vim.fn.expand("$MYVIMRC"), ":h") .. "/init_local.lua"
if vim.fn.filereadable(init_local) == 1 then
	dofile(init_local)
end
