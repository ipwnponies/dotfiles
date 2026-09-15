---@type LazyPluginSpec | LazyPluginSpec[]
return {
	-- Lang-specific
	{ "voithos/vim-python-matchit" },

	-- Editing
	{ "tpope/vim-commentary", enabled = lv_off("editing") },
	{ "machakann/vim-sandwich", enabled = lv_off("editing") },
	{ "tpope/vim-sensible" },
	{ "tpope/vim-endwise", enabled = lv_off("editing") },
	{ "junegunn/vim-easy-align" },
	{ "michaeljsmith/vim-indent-object", enabled = lv_off("editing") },
	{ "jeetsukumaran/vim-indentwise" },
	{ "mattn/vim-xxdcursor" },
	{ "tpope/vim-sleuth" },

	-- Usability
	{ "junegunn/vim-peekaboo" },
	{ "tpope/vim-unimpaired" },
	{ "nvim-telescope/telescope.nvim", branch = "master", enabled = lv_off("picker") },

	-- Pretty
	{ "haya14busa/is.vim" },
}
