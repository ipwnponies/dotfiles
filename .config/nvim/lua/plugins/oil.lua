---@type LazyPluginSpec | LazyPluginSpec[]
return {
	"stevearc/oil.nvim",
	enabled = lv_off("explorer"),
	---@module 'oil'
	---@type oil.SetupOpts
	opts = {},
	-- Optional dependencies
	dependencies = {
		{ "echasnovski/mini.icons", opts = {} },
	},
	-- Lazy loading is not recommended because it is very tricky to make it work correctly in all situations.
	lazy = false,
}
