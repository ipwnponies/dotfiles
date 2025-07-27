---@module 'lazy'
---@type LazyPluginSpec | LazyPluginSpec[]
return {
	-- Git plugins
	{ "junegunn/gv.vim" },
	{ "airblade/vim-gitgutter" },
	{ "tpope/vim-fugitive" },
	{ "ruanyl/vim-gh-line" },

	-- Lang-specific
	{ "w0rp/ale" },
	{ "voithos/vim-python-matchit" },

	-- Editing
	{ "tpope/vim-commentary" },
	{ "machakann/vim-sandwich" },
	{ "tpope/vim-sensible" },
	{ "tpope/vim-endwise" },
	{ "Yggdroot/indentLine" },
	{ "junegunn/vim-easy-align" },
	{ "AndrewRadev/sideways.vim" },
	{ "AndrewRadev/splitjoin.vim" },
	{ "michaeljsmith/vim-indent-object" },
	{ "jeetsukumaran/vim-indentwise" },
	{ "mattn/vim-xxdcursor" },
	{ "tpope/vim-sleuth" },

	-- Usability
	{ "mbbill/undotree", cmd = "UndotreeToggle" },
	{
		"junegunn/fzf.vim",
		dependencies = {
			"junegunn/fzf",
		},
		cmd = { "Files", "GFiles", "Lines", "BLines", "History", "Filetypes", "Jumps", "HelpTags" },
	},
	{ "junegunn/vim-peekaboo" },
	{ "haya14busa/vim-asterisk" },
	{ "smoka7/hop.nvim", version = "v2.7.2" },
	{ "tpope/vim-unimpaired" },
	{ "ipwnponies/vim-agriculture" },
	{ "nvim-telescope/telescope.nvim", branch = "0.1.x" },

	-- Pretty
	{ "vim-airline/vim-airline" },
	{ "sainnhe/sonokai" },
	{ "haya14busa/is.vim" },

	-- IDE
	{ "j-hui/fidget.nvim" },
	{ "hrsh7th/nvim-cmp" },
	{ "hrsh7th/cmp-buffer" },
	{ "hrsh7th/cmp-cmdline" },
	{ "hrsh7th/cmp-nvim-lsp-document-symbol" },
	{ "hrsh7th/cmp-nvim-lsp-signature-help" },
	{ "rafamadriz/friendly-snippets" },
	{ "L3MON4D3/LuaSnip" },
	{ "saadparwaiz1/cmp_luasnip" },
	{ "kdheepak/lazygit.nvim" },

	-- Misc
	{
		"glacambre/firenvim",
		build = function()
			vim.fn["firenvim#install"](0)
		end,
	}, -- Firefox plugin to integrate Neovim
}
