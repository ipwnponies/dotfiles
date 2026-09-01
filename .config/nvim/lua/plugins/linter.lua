---@type LazyPluginSpec | LazyPluginSpec[]
return {
	{
		"mfussenegger/nvim-lint",
		event = { "BufReadPost", "BufNewFile" },
		config = function()
			local lint = require("lint")

			lint.linters_by_ft = {
				sh = { "shellcheck" },
				bash = { "shellcheck" },
			}

			local function has_linters(ft)
				local linters = lint.linters_by_ft[ft]
				if type(linters) == "table" then
					return #linters > 0
				end
				return false
			end

			local group = vim.api.nvim_create_augroup("UserLintAutoCmds", { clear = true })
			vim.api.nvim_create_autocmd({ "BufWritePost", "InsertLeave" }, {
				group = group,
				callback = function(args)
					local ft = vim.bo[args.buf].filetype
					if ft ~= "" and has_linters(ft) then
						lint.try_lint(nil, { bufnr = args.buf })
					end
				end,
			})
		end,
	},
}
