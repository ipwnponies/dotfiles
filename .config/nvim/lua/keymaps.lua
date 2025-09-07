-- Must be set early, so that plugin mappings map to it
vim.g.mapleader = " "

-- Switch buffers quickly with <TAB>
vim.api.nvim_set_keymap("n", "<TAB>", "<Cmd>bnext<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<S-TAB>", "<Cmd>bprevious<CR>", { noremap = true, silent = true })

vim.keymap.set("i", "jk", "<esc>", { silent = true }) -- Exit insert mode by typing 'jk'
vim.keymap.set("i", "<c-l>", "<c-g>u<esc>1z=`]a<c-g>u", { silent = true }) -- Fix last spelling error and return to insert mode
vim.keymap.set("n", "Y", "y$", { silent = true }) -- Yank to end of line

-- Faster scroll remaps
---@param key string Scroll direction key ('<c-e>' or '<c-y>')
local scroll = function(key)
	---Returns a function that scrolls by count*5 lines in the given direction.
	local lines = vim.v.count1 * 5
	return function()
		return ("<Cmd>execute 'normal! " .. lines .. key .. "'<CR>")
	end
end
vim.keymap.set({ "n", "v" }, "<C-e>", scroll("<c-e>"), { noremap = true, silent = true, expr = true }) -- Scroll down
vim.keymap.set({ "n", "v" }, "<C-y>", scroll("<c-y>"), { noremap = true, silent = true, expr = true }) -- Scroll up

-- Buffer delete but without closing window
vim.keymap.set("n", "<leader>bd", function()
	---Deletes current buffer and switches to alternate or next listed buffer.
	local target = vim.fn.bufnr("%")
	local alt = vim.fn.bufnr("#")
	if alt == -1 then
		local bufs = vim.fn.getbufinfo({ buflisted = 1, bufloaded = 1 })

		for _, buf in ipairs(bufs) do
			if buf.bufnr ~= target then
				alt = buf.bufnr
				break
			end
		end
	end

	if alt then
		vim.api.nvim_win_set_buf(0, alt)
		vim.api.nvim_buf_delete(target, {})
	end
end, { silent = true })
