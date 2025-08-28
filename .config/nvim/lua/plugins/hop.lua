---@type LazyPluginSpec | LazyPluginSpec[]
return {
	{
		"smoka7/hop.nvim",
		version = "v2.7.2",
		-- This is useful in all editing situations.
		-- Also allows for FileType autocommands to be set up
		lazy = false,
		---@module 'hop'
		---@type Options | table<any>
		opts = {
			uppercase_labels = true,
		},
		keys = {
			{ ";", "<Plug>(hop-prefix)", mode = "" },
			{ "<Plug>(hop-prefix)/", "<Cmd>HopPatternMW<CR>", mode = "" },
			{ "<Plug>(hop-prefix)w", "<Cmd>HopWordAC<CR>", mode = "" },
			{ "<Plug>(hop-prefix)W", "<Cmd>HopWordBC<CR>", mode = "" },
			{
				"<Plug>(hop-prefix)e",
				function()
					local hop = require("hop")
					local hint = require("hop.hint")
					hop.hint_words({
						hint_position = hint.HintPosition.END,
						direction = hint.HintDirection.AFTER_CURSOR,
					})
				end,
			},
			{
				"<Plug>(hop-prefix)E",
				function()
					local hop = require("hop")
					local hint = require("hop.hint")

					hop.hint_words({
						hint_position = hint.HintPosition.END,
						direction = hint.HintDirection.BEFORE_CURSOR,
					})
				end,
			},
			{ "<Plug>(hop-prefix)c", "<Cmd>HopCamelCaseAC<CR>", mode = "" },
			{ "<Plug>(hop-prefix)C", "<Cmd>HopCamelCaseBC<CR>", mode = "" },
			{ "<Plug>(hop-prefix)f", "<Cmd>HopChar1CurrentLine<CR>", mode = "" },
			{ "<Plug>(hop-prefix)j", "<Cmd>HopLineStartMW<CR>", mode = "" },
			{
				"<Plug>(hop-prefix)t",
				function()
					require("hop").hint_char1({ hint_offset = -1, current_line_only = true })
				end,
			},
			mode = "",
		},
		config = function(_, opts)
			local hop = require("hop")
			hop.setup(opts)

			vim.api.nvim_create_autocmd("FileType", {
				pattern = "python",
				callback = function(args)
					vim.api.nvim_buf_create_user_command(args.buf, "HopPythonParamsBye", function()
						local hop = require("hop")
						local regex = [[\v(def\s+\w+\s*\(.*)@<=\s*(\zs[^,)]+,?\ze).*\)]]
						local jump_regex = require("hop.jump_regex")
						local taco = jump_regex.regex_by_case_searching(regex, false, hop.opts)
						hop.hint_with_regex(taco, hop.opts)
					end, { desc = "Hop python" })
				end,
			})
		end,
	},
}
