-- Per-domain feature flags for incremental LazyVim adoption.
-- false = current (legacy) behavior; true = LazyVim-equivalent plugin/config.
--
-- Flip one domain at a time in init_local.lua (gitignored) to dogfood before
-- committing. Example init_local.lua:
--   vim.g.lv.motion = true  -- trial flash.nvim on this machine only
vim.g.lv = {
  cmp        = true,   -- already on blink.cmp (matches LazyVim default)
  picker     = false,  -- snacks.picker  vs  fzf-lua + fzf.vim
  explorer   = false,  -- LazyVim neo-tree config  vs  current neo-tree/oil
  motion     = false,  -- flash.nvim  vs  hop.nvim
  git        = false,  -- gitsigns + snacks.lazygit/gitbrowse  vs  gitgutter/lazygit.nvim/gh-line
  statusline = false,  -- lualine + bufferline  vs  vim-airline
  editing    = false,  -- mini.ai/surround/pairs  vs  sandwich/indent-object/endwise
  ui         = false,  -- which-key/noice/todo-comments/snacks.indent  vs  current
  treesitter = false,  -- LazyVim treesitter spec  vs  current spec
  ai         = false,  -- LazyVim copilot extras  vs  custom claude/codex switch
}

--- Returns a function evaluating true when named domain is enabled.
--- Use as: enabled = lv_on("motion")
---@param domain string key in vim.g.lv
---@return fun(): boolean
function _G.lv_on(domain)
  return function()
    return vim.g.lv[domain] == true
  end
end

--- Returns a function evaluating true when named domain is disabled (legacy active).
--- Use as: enabled = lv_off("motion")
---@param domain string key in vim.g.lv
---@return fun(): boolean
function _G.lv_off(domain)
  return function()
    return vim.g.lv[domain] ~= true
  end
end
