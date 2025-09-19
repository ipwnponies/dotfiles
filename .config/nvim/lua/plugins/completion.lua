local copilotchat_source = {
	is_available = function()
		return true
	end,

	get_trigger_characters = function()
		return { "#" }
	end,
	get_debug_name = function()
		return "copilotchat_functions"
	end,

	complete = function(_, params, callback)
		-- From the docs, predefined functions
		local copilotchat_functions = {
			"#buffer", -- Retrieves content from a specific buffer
			"#buffers:visible", -- Fetches content from multiple buffers
			"#diagnostics:current", -- Collects code diagnostics (errors, warnings)
			"#file:", -- Reads content from a specified file path
			"#gitdiff:staged", -- Retrieves git diff information
			"#gitstatus", -- Retrieves git status information
			"#glob:**/*.lua", -- Lists filenames matching a pattern in workspace
			"#grep:TODO", -- Searches for a pattern across files in workspace
			"#quickfix", -- Includes content of files in quickfix list
			"#register:+", -- Provides access to specified Vim register
			"#selection", -- Includes the current visual selection
			"#url:", -- Fetches content from a specified URL
		}
		local input = params.context.cursor_before_line
		local matches = {}
		if input:find("#") then
			for _, func in ipairs(copilotchat_functions) do
				table.insert(matches, { label = func })
			end
		end
		callback(matches)
	end,
}

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

			cmp.register_source("copilotchat_functions", copilotchat_source)

			cmp.setup.filetype("copilot-chat", {
				sources = cmp.config.sources({
					{ name = "copilotchat_functions", keyword_length = 1, max_item_count = 5 },
				}, sources),
			})
		end,
	},
}
