---@type LazyPluginSpec | LazyPluginSpec[]
return {
	{
		"RRethy/vim-illuminate",
		event = "LspAttach",
		keys = {
			{
				"[r",
				function()
					require("illuminate").goto_prev_reference(false)
				end,
				desc = "Previous Reference",
			},
			{
				"]r",
				function()
					require("illuminate").goto_next_reference(false)
				end,
				desc = "Next Reference",
			},
		},
		config = function()
			vim.api.nvim_set_hl(0, "IlluminatedWordText", { underline = true })
			vim.api.nvim_set_hl(0, "IlluminatedWordRead", { underline = true, bg = "#2c4070" })
			vim.api.nvim_set_hl(0, "IlluminatedWordWrite", { underline = true, bg = "salmon" })
			vim.api.nvim_set_hl(0, "illuminatedWord", { link = "Search" })

			vim.g.Illuminate_delay = 100
			vim.g.Illuminate_ftHighlightGroups = {
				qf = { "" },
				["javascript.jsx:blacklist"] = {
					"jsImport",
					"jsExport",
					"jsExportDefault",
					"jsStorageClass",
					"jsGlobalNodeObjects",
					"jsClassKeyword",
					"jsOperatorKeyword",
					"jsExtendsKeyword",
					"jsFrom",
					"jsConditional",
					"jsReturn",
				},
				python = { "", "pythonString", "pythonFunction", "pythonDottedName", "pythonNone", "pythonComment" },
			}
		end,
	},
	{
		"folke/lazydev.nvim",
		ft = "lua", -- only load on lua files
		---@class (partial) opts : lazydev.Config
		---@type opts
		opts = {
			library = {
				-- See the configuration section for more details
				-- Load luvit types when the `vim.uv` word is found
				{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
			},
		},
	},
	{
		"gfanto/fzf-lsp.nvim",
		dependencies = { "nvim-lua/plenary.nvim", "junegunn/fzf" },
		event = "LspAttach",
		keys = {
			{
				"gl",
				function()
					LspAction()
				end,
				mode = "n",
				noremap = true,
				silent = true,
				desc = "LSP Action",
			},
		},

		config = function()
			local function executeLua(action)
				local fzf_lsp_action = {
					Definition = true,
					References = true,
					Declaration = true,
					TypeDefinition = true,
					Implementation = true,
				}

				if fzf_lsp_action[action] then
					vim.cmd(action)
				else
					local ok, _ = pcall(vim.lsp.buf[action])
					if not ok then
						vim.api.nvim_err_writeln("Invalid LSP action: " .. action)
					end
				end
			end

			function LspAction()
				local actions = {
					"Definition",
					"References",
					"Declaration",
					"TypeDefinition",
					"Implementation",
					"hover",
					"signature_help",
					"code_action",
					"format",
					"execute_command",
					"workspace_symbol",
					"document_symbol",
					"rename",
				}
				vim.fn["fzf#run"](vim.fn["fzf#wrap"]({
					source = actions,
					sink = executeLua,
				}))
			end

			vim.api.nvim_buf_create_user_command(0, "LspAction", LspAction, {})
		end,
	},
}
