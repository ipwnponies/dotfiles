---@type LazyPluginSpec | LazyPluginSpec[]
return {
	{
		"Saghen/blink.cmp",
		version = "1.*",
		dependencies = {
			{
				"saghen/blink.compat",
				version = "2.*",
			},
			"rafamadriz/friendly-snippets",
			"moyiz/blink-emoji.nvim",
			{
				"fang2hou/blink-copilot",
				dependencies = { "zbirenbaum/copilot.lua" },
			},
			"xieyonn/blink-cmp-dat-word",
			"hrsh7th/cmp-calc",
		},
		---@type blink.cmp.Config
		opts = {
			signature = { enabled = true },
			keymap = {
				preset = "enter",
				["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
				["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
				["<esc>"] = { "cancel", "fallback" },
			},
			completion = {
				menu = {
					auto_show = true,
					draw = {
						columns = {
							{ "kind_icon", "kind", gap = 2 },
							{ "label", "label_description", gap = 2 },
							{ "source_name" },
						},
					},
				},
				list = {
					selection = {
						preselect = false,
					},
				},
				documentation = { auto_show = true, auto_show_delay_ms = 00 },
			},

			sources = {
				-- copilot/copilotchat_functions only registered when the Copilot plugins are enabled; see plugins/copilot.lua.
				default = (function()
					local default_sources = { "lsp", "path", "snippets", "buffer", "emoji", "datword", "calc" }
					if vim.env.COPILOT_ENABLED == "1" then
						vim.list_extend(default_sources, { "copilot", "copilotchat_functions" })
					end
					return default_sources
				end)(),
				providers = {
					lsp = {
						min_keyword_length = 0,
						fallbacks = {},
						score_offset = 20, -- the higher the number, the higher the priority
						max_items = 6,
					},
					buffer = {
						min_keyword_length = 3,
						score_offset = -5, -- the higher the number, the higher the priority
					},
					copilot = {
						name = "copilot",
						module = "blink-copilot",
						enabled = function()
							return vim.bo.buftype ~= "terminal"
						end,
						score_offset = 5,
						async = true,
						opts = {
							max_completions = 1,
							max_attempts = 1,
							debounce = 2000,
							auto_refresh = {
								forward = false,
								backward = false,
							},
						},
					},
					["copilotchat_functions"] = {
						name = "CopilotChat functions",
						module = "completions.copilotchat_functions",
						min_keyword_length = 0,
						score_offset = 1000, -- the higher the number, the higher the priority
					},
					emoji = {
						module = "blink-emoji",
						name = "Emoji",
						score_offset = 15, -- Tune by preference
						opts = {
							insert = true, -- Insert emoji (default) or complete its name
							---@type string|table|fun():table
							trigger = function()
								return { ":" }
							end,
						},
					},
					datword = {
						name = "Word",
						module = "blink-cmp-dat-word",
						opts = {
							spellsuggest = true,
							paths = {
								"/usr/share/dict/words",
							},
						},
						min_keyword_length = 5,
						score_offset = -50,
					},
					calc = {
						name = "calc",
						module = "blink.compat.source",
						score_offset = 20,
						min_keyword_length = 3,
					},
				},
			},

			fuzzy = { implementation = "prefer_rust_with_warning" },
		},
	},
}
