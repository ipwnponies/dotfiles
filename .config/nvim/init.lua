-- init.lua
require("settings") -- basic options
require("keymaps") -- key mappings
require("config.lazy") -- plugin manager and plugins

local xdg_config_home = os.getenv("XDG_CONFIG_HOME") or "~/.config"
-- Fallthrough to loading original vimscript
vim.cmd("source " .. xdg_config_home .. "/nvim/init.vim")
