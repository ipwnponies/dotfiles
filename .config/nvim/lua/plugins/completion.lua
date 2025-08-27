---@type LazyPluginSpec | LazyPluginSpec[]
return {
	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-cmdline",
			{
				"saadparwaiz1/cmp_luasnip",
				dependencies = {
					"L3MON4D3/LuaSnip",
					version = "v2.*",
					dependencies = { "rafamadriz/friendly-snippets" },
				},
			},
		},
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
				{ name = "emoji", keyword_length = 2, max_item_count = 5 },
				{ name = "calc", keyword_length = 2, max_item_count = 5 },
				{ name = "copilot", keyword_length = 2, max_item_count = 5 },
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
				sources = {
					{ name = "nvim_lsp_document_symbol", keyword_length = 2, max_item_count = 5 },
					{ name = "buffer", keyword_length = 2, max_item_count = 5 },
				},
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
		end,
	},
}
