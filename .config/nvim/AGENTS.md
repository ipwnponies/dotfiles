# Neovim Config

Plugin manager: **lazy.nvim**. Everything below reflects how this repo uses it.

## Directory layout

```
init.lua                  # entry point — loads modules in order
lua/
  settings.lua            # vim.opt.* options (ex: tabstop, wrap)
  keymaps.lua             # global key mappings not tied to a plugin
  autocmds.lua            # autocommands
  vim_settings.lua        # legacy vimscript-style settings, ported to lua
  colours.lua             # colorscheme and highlight overrides
  binary-editing.lua      # binary file utilities
  config/
    lazy.lua              # lazy.nvim bootstrap and setup
    plugin_settings.lua   # post-plugin global configuration
  plugins/
    *.lua                 # one file per plugin (or logical group)
```

`init_local.lua` (gitignored) is sourced at the end of `init.lua` for
machine-specific overrides.

## Plugin files

Each file in `lua/plugins/` returns a `LazyPluginSpec` or a list of specs.
lazy.nvim auto-imports all files in this directory — no manual registration needed.

Minimal plugin spec:
```lua
return {
  "author/plugin-name",
}
```

Full spec with common fields:
```lua
return {
  "author/plugin-name",
  dependencies = { "other/dep" },   -- loaded before this plugin
  event = "BufReadPost",            -- lazy-load trigger (event name)
  keys = { { "<leader>x", ... } },  -- lazy-load on keymap; define keys here
  cmd = { "MyCommand" },            -- lazy-load on command
  ft = { "python", "lua" },         -- lazy-load on filetype
  opts = { option = true },         -- passed to plugin's setup() automatically
  config = function(_, opts)        -- use instead of opts when custom logic needed
    require("plugin-name").setup(opts)
  end,
}
```

Use `opts` when the plugin follows the standard `setup(opts)` convention.
Use `config` when you need to do anything beyond calling `setup`.

## Setting nvim options and variables

```lua
vim.opt.name = value    -- set option (like :set name=value)
vim.g.name = value      -- global variable (like :let g:name = value) — used for plugin config
vim.b.name = value      -- buffer-local variable
vim.w.name = value      -- window-local variable
vim.o.name = value      -- global option (alias for vim.opt on global-scope options)
```

Plugin configuration variables (e.g. `vim.g.mapleader`) must be set before
the plugin loads. Put them in `settings.lua` or at the top of the relevant
plugin file, before `require`.

## Keymaps

```lua
vim.keymap.set(mode, lhs, rhs, opts)
-- mode: "n", "i", "v", "x", "t", or a list
-- opts: { noremap=true, silent=true, desc="Description" }
```

Leader is `<Space>` (set in `settings.lua`). Plugin-specific keymaps belong
in the `keys` field of the plugin spec so they trigger lazy-loading.
Global keymaps unrelated to plugins go in `keymaps.lua`.

## Validating changes

There is no test suite. To check for errors:

```bash
nvim --headless -c "quit"   # exits non-zero if startup fails
```

Inside nvim:
- `:Lazy` — plugin status, shows load errors
- `:checkhealth` — plugin health checks
- `:messages` — recent error/warning messages

lazy.nvim caches plugin specs; after editing a plugin file run `:Lazy reload`
or restart nvim for changes to take effect.

## Adding a new plugin

1. Create `lua/plugins/<name>.lua` returning a LazyPluginSpec.
2. Use `keys` or `event` or `ft` to lazy-load rather than loading eagerly.
3. Prefer `opts` over writing a full `config` function unless custom logic is needed.
4. If the plugin needs a global variable set before load, put `vim.g.var = val`
   before the spec table or in `settings.lua`.
