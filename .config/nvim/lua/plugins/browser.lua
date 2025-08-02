--- Plugins for integrating Neovim with external programs (e.g., browser extensions).
-- Firenvim embeds Neovim in browser textareas.
---@module 'lazy'
---@type LazyPluginSpec | LazyPluginSpec[]
return {
	{
		"glacambre/firenvim",
		build = function()
			vim.fn["firenvim#install"](0)
		end,
		lazy = not vim.g.started_by_firenvim,
		config = function()
			vim.g.firenvim_config = {
				localSettings = {
					[".*"] = {
						selector = "textarea, input",
						takeover = "never",
					},
				},
			}
			vim.opt.guifont = "FiraCode_Nerd_Font_Mono:h8"
			vim.w.airline_disable_statusline = 1
			vim.opt.laststatus = 0
			vim.opt.showtabline = 0
			vim.opt.number = false
			vim.opt.cursorline = false
			vim.opt.signcolumn = "no"

			local id = vim.api.nvim_create_augroup("ExpandLinesOnTextChanged", { clear = true })
			vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
				group = id,
				callback = function()
					local max_height = 40

					-- To avoid constant jitters, we only contract when the content is much smaller than window
					-- As we get to single-digit line count, this is effectively 1:1 between content and window
					local shrink = {
						threshold = 0.7, -- Avoids constant jitters
						buffer = 0.9, -- Shrink such that content is 90% of height
					}
					local height = vim.api.nvim_win_text_height(0, {}).all

					if height > vim.o.lines and height < max_height then
						vim.o.lines = height
					elseif height < vim.o.lines * shrink.threshold then
						-- Shrink with hysteresis
						vim.o.lines = math.floor(height / shrink.buffer)
					end
				end,
			})
		end,
	},
}
