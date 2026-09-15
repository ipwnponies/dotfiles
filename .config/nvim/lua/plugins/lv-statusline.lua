-- LazyVim statusline domain: lualine (statusline) + bufferline (tabline).
-- Active when vim.g.lv.statusline = true; legacy vim-airline is gated off in pretty.lua.
---@type LazyPluginSpec[]
return {
	{
		"nvim-lualine/lualine.nvim",
		enabled = lv_on("statusline"),
		cond = function()
			return not vim.g.started_by_firenvim
		end,
		event = "VeryLazy",
		opts = {
			options = {
				theme = "auto",
				globalstatus = true,
				disabled_filetypes = { statusline = { "dashboard", "alpha", "starter" } },
			},
			sections = {
				lualine_a = { "mode" },
				lualine_b = { "branch" },
				lualine_c = { "diagnostics" },
				lualine_x = { "filename" },
				lualine_y = { "filetype", "progress" },
				lualine_z = { "location" },
			},
			extensions = { "neo-tree", "lazy" },
		},
	},
	{
		"akinsho/bufferline.nvim",
		enabled = lv_on("statusline"),
		event = "VeryLazy",
		keys = {
			{ "<Tab>", "<cmd>BufferLineCycleNext<cr>", desc = "Next buffer" },
			{ "<S-Tab>", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev buffer" },
		},
		opts = {
			options = {
				diagnostics = "nvim_lsp",
				always_show_bufferline = false,
				offsets = {
					{
						filetype = "neo-tree",
						text = "Neo-tree",
						highlight = "Directory",
						text_align = "left",
					},
				},
			},
		},
	},
}
