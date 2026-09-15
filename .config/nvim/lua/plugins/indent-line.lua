---@type LazyPluginSpec | LazyPluginSpec[]
return {
	{
		"lukas-reineke/indent-blankline.nvim",
		enabled = lv_off("ui"),
		main = "ibl",
		---@module "ibl"
		---@type ibl.config
		opts = {},
	},
}
