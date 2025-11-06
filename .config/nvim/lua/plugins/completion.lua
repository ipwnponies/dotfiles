-- Pick which engine runs where
vim.g.cmp_engine = "blink" -- "cmp" | "blink"

---@type LazyPluginSpec | LazyPluginSpec[]
return {
	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-cmdline",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-nvim-lsp-document-symbol",
			"hrsh7th/cmp-nvim-lsp-signature-help",
			"hrsh7th/cmp-calc",
			"f3fora/cmp-spell",
			{
				"saadparwaiz1/cmp_luasnip",
				dependencies = {
					"L3MON4D3/LuaSnip",
					version = "v2.*",
					dependencies = { "rafamadriz/friendly-snippets" },
				},
			},
		},
		enabled = vim.g.cmp_engine == "cmp",
		config = function()
			local luasnip = require("luasnip")
			local cmp = require("cmp")

			local get_bufnrs = function()
				local bufs = {}
				for _, win in ipairs(vim.api.nvim_list_wins()) do
					bufs[vim.api.nvim_win_get_buf(win)] = true
				end
				return vim.tbl_keys(bufs)
			end

			local sources = {
				{ name = "nvim_lsp" },
				{ name = "nvim_lsp_signature_help" },
				{ name = "buffer", keyword_length = 5, max_item_count = 5, option = { get_bufnrs = get_bufnrs } },
				{ name = "path" },
				{ name = "nvim_lua" },
				{ name = "spell", keyword_length = 5, max_item_count = 5 },
				{ name = "calc", keyword_length = 2, max_item_count = 5 },
				{ name = "luasnip" },
			}

			cmp.setup({
				sources = sources,
				---@type cmp.MatchingConfig | table<any>
				matching = {
					-- The value without fuzziness is multi-word completion
					disallow_fuzzy_matching = false,
					disallow_fullfuzzy_matching = false,
					-- Needs to match on prefix of components. Components are tokenized vim words
					disallow_partial_fuzzy_matching = true,
					-- Need to match prefix of first word. To search later, need to break prefix match and fuzzy on first word. Super weird behaviour.
					disallow_partial_matching = false,
					-- completion needs first letter to match: https://github.com/hrsh7th/nvim-cmp/blob/04e0ca376d6abdbfc8b52180f8ea236cbfddf782/lua/cmp/matcher.lua#L98
					-- this is special case of partial fuzzy matching
					disallow_prefix_unmatching = false,
				},
				-- snippet = {
				-- 	expand = function(args)
				-- 		luasnip.lsp_expand(args.body)
				-- 		print("🌮")
				-- 	end,
				-- },
				mapping = cmp.mapping.preset.insert({
					["<C-Space>"] = cmp.mapping.complete({}),
					["<CR>"] = cmp.mapping(function(fallback)
						if luasnip.expandable() then
							luasnip.expand()
						elseif cmp.get_selected_entry() then
							cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace })
						else
							fallback()
						end
					end),
					["<Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_next_item()
						elseif luasnip.expand_or_locally_jumpable() then
							luasnip.expand_or_jump()
						else
							fallback()
						end
					end, { "i", "s" }),
					["<S-Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_prev_item()
						elseif luasnip.locally_jumpable(-1) then
							luasnip.jump(-1)
						else
							fallback()
						end
					end, { "i", "s" }),

					["<C-b>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.mapping.scroll_docs(-4)()
						else
							fallback()
						end
					end),
					["<C-f>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.mapping.scroll_docs(4)()
						else
							fallback()
						end
					end),
				}),
			})

			-- Command line completion
			cmp.setup.cmdline({ "/", "?" }, {
				mapping = cmp.mapping.preset.cmdline(),
				window = { completion = cmp.config.window.bordered({ col_offset = 0 }) },
				sources = cmp.config.sources({
					{ name = "nvim_lsp_document_symbol", keyword_length = 2, max_item_count = 5 },
				}, {
					{ name = "buffer", keyword_length = 2, max_item_count = 5 },
				}),
			})
			cmp.setup.cmdline(":", {
				mapping = cmp.mapping.preset.cmdline(),
				window = { completion = cmp.config.window.bordered({ col_offset = 0 }) },
				sources = cmp.config.sources({
					{ name = "cmdline", keyword_length = 2, max_item_count = 8 },
					{ name = "path" },
					{ name = "buffer", keyword_length = 3, max_item_count = 5 },
				}),
			})

			require("luasnip.loaders.from_vscode").lazy_load()

			local copilotchat_source = require("completions.copilotchat_functions")
			cmp.register_source("copilotchat_functions", copilotchat_source)
			cmp.setup.filetype("copilot-chat", {
				sources = cmp.config.sources({
					{ name = "copilotchat_functions", keyword_length = 1, max_item_count = 5 },
				}, sources),
			})
		end,
	},
	{
		"Saghen/blink.cmp",
		version = "1.*",
		enabled = vim.g.cmp_engine == "blink",
		dependencies = {
			{
				"saghen/blink.compat",
				version = "2.*",
			},
			"ray-x/cmp-treesitter",
			"uga-rosa/cmp-dictionary",
			"hrsh7th/cmp-nvim-lsp-signature-help",
			"rafamadriz/friendly-snippets",
			"moyiz/blink-emoji.nvim",
			{
				"fang2hou/blink-copilot",
				dependencies = { "zbirenbaum/copilot.lua" },
			},
			"xieyonn/blink-cmp-dat-word",
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
				documentation = { auto_show = true, auto_show_delay_ms = 00 },
			},

			sources = {
				default = {
					"lsp",
					"path",
					"snippets",
					"copilot",
					"buffer",
					"copilotchat_functions",
					"emoji",
					"datword",
				},
				providers = {
					lsp = {
						min_keyword_length = 0,
						fallbacks = {},
						score_offset = 10, -- the higher the number, the higher the priority
						max_items = 6,
					},
					buffer = {
						min_keyword_length = 3,
						score_offset = -10, -- the higher the number, the higher the priority
					},
					copilot = {
						name = "copilot",
						module = "blink-copilot",
						score_offset = 100,
						async = true,
					},
					["copilotchat_functions"] = {
						name = "copilotchat-functions",
						module = "completions.copilotchat_functions",
						opts = { some_option = "some value" },
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
					},
				},
			},

			fuzzy = { implementation = "prefer_rust_with_warning" },
		},
	},
}
