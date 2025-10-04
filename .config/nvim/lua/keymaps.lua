-- Must be set early, so that plugin mappings map to it
vim.g.mapleader = " "

-- Switch buffers quickly with <TAB>
vim.api.nvim_set_keymap("n", "<TAB>", "<Cmd>bnext<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<S-TAB>", "<Cmd>bprevious<CR>", { noremap = true, silent = true })

vim.keymap.set("i", "jk", "<esc>", { silent = true }) -- Exit insert mode by typing 'jk'
vim.keymap.set("i", "<c-l>", "<c-g>u<esc>1z=`]a<c-g>u", { silent = true }) -- Fix last spelling error and return to insert mode
vim.keymap.set("n", "Y", "y$", { silent = true }) -- Yank to end of line
vim.keymap.set("n", "<m-o>", "<c-i>", { silent = true }) -- Yank to end of line

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

--- Quickfix/Location List toggles
---@param is_quickfix boolean true for quickfix, false for location list
local function toggle_qf(is_quickfix)
	local list_getter = is_quickfix and vim.fn.getqflist or function(what)
		return vim.fn.getloclist(0, what)
	end
	return function()
		if list_getter({ winid = true }) ~= 0 then
			vim.cmd("cclose")
		else
			vim.cmd("cwindow")
		end
	end
end

vim.keymap.set("n", "<leader><F5>", toggle_qf(true), { silent = true })
vim.keymap.set("n", "<leader><F6>", toggle_qf(false), { silent = true })

-- Window movement remaps
vim.keymap.set("n", "<c-j>", "<c-w><c-j>", { silent = true }) -- Move to window below
vim.keymap.set("n", "<c-k>", "<c-w><c-k>", { silent = true }) -- Move to window above
vim.keymap.set("n", "<c-l>", "<c-w><c-l>", { silent = true }) -- Move to window right
vim.keymap.set("n", "<c-h>", "<c-w><c-h>", { silent = true }) -- Move to window left

-- Command-line
vim.keymap.set("c", "<c-p>", "<up>", { silent = false }) -- Previous selection in completion menu
vim.keymap.set("c", "<c-n>", "<down>", { silent = false }) -- Next selection in completion menu
vim.keymap.set("c", "<c-a>", "<c-b>", { silent = false }) -- Move to beginning of line

-- Terminal mode: <C-Space> to normal mode
vim.keymap.set("t", "<C-Space>", "<C-\\><C-n>", { silent = true })
