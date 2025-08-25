---@module 'lazy'
---@type LazyPluginSpec | LazyPluginSpec[]
return {
	-- Lang-specific
	{ "voithos/vim-python-matchit" },

	-- Editing
	{ "tpope/vim-commentary" },
	{ "machakann/vim-sandwich" },
	{ "tpope/vim-sensible" },
	{ "tpope/vim-endwise" },
	{ "junegunn/vim-easy-align" },
	{ "AndrewRadev/sideways.vim" },
	{ "michaeljsmith/vim-indent-object" },
	{ "jeetsukumaran/vim-indentwise" },
	{ "mattn/vim-xxdcursor" },
	{ "tpope/vim-sleuth" },

	-- Usability
	{ "mbbill/undotree", cmd = "UndotreeToggle" },
	{ "junegunn/vim-peekaboo" },
	{ "haya14busa/vim-asterisk" },
	{ "tpope/vim-unimpaired" },
	{ "nvim-telescope/telescope.nvim", branch = "0.1.x" },

	-- Pretty
	{ "vim-airline/vim-airline" },
	{ "sainnhe/sonokai" },
	{ "haya14busa/is.vim" },
}
