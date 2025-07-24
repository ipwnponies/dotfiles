vim.g["airline#extensions#tabline#enabled"] = 1
vim.g.sonokai_style = "shusia"
vim.cmd([[colorscheme sonokai]])

local function hop_setup()
	local hop = require("hop")
	hop.hint = require("hop.hint")

	local modes = { "n", "v", "o" }

	-- Set leader
	vim.keymap.set(modes, ";", "<Plug>(hop-prefix)", { noremap = true, silent = true })

	vim.keymap.set(modes, "<Plug>(hop-prefix)t", function()
		hop.hint_char1({ hint_offset = -1, direction = nil, current_line_only = true })
	end, { noremap = true, silent = true })
end

hop_setup()
