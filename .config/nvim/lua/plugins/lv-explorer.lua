---@type LazyPluginSpec | LazyPluginSpec[]
return {
	{
		"nvim-neo-tree/neo-tree.nvim",
		enabled = lv_on("explorer"),
		branch = "v3.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"echasnovski/mini.icons",
			"MunifTanjim/nui.nvim",
			{
				"s1n7ax/nvim-window-picker",
				version = "2.*",
				config = function()
					require("window-picker").setup({
						filter_rules = {
							include_current_win = false,
							autoselect_one = true,
							bo = {
								filetype = { "neo-tree", "neo-tree-popup", "notify" },
								buftype = { "terminal", "quickfix" },
							},
						},
					})
				end,
			},
			{
				"antosha417/nvim-lsp-file-operations",
				dependencies = { "nvim-lua/plenary.nvim" },
				config = function()
					require("lsp-file-operations").setup()
				end,
			},
		},
		keys = {
			{ "<leader>e", "<Cmd>Neotree reveal<CR>", desc = "Explorer: Reveal" },
			{ "<leader>E", "<Cmd>Neotree toggle<CR>", desc = "Explorer: Toggle Root" },
		},
		--- @type neotree.Config
		opts = {
			close_if_last_window = false,
			popup_border_style = "NC",
			enable_git_status = true,
			enable_diagnostics = true,
			open_files_do_not_replace_types = { "terminal", "trouble", "qf" },
			open_files_using_relative_paths = false,
			default_component_configs = {
				indent = {
					indent_size = 2,
					padding = 1,
					with_markers = true,
					indent_marker = "│",
					last_indent_marker = "└",
					highlight = "NeoTreeIndentMarker",
					with_expanders = nil,
					expander_collapsed = "",
					expander_expanded = "",
					expander_highlight = "NeoTreeExpander",
				},
				icon = {
					folder_closed = "",
					folder_open = "",
					folder_empty = "󰀌",
					folder_empty_open = "󰀌",
					provider = function(icon, node)
						local text, hl
						if node.type == "file" or node.type == "directory" then
							local mini_icons = require("mini.icons")
							text, hl = mini_icons.get(node.type, node.name)
							if node:is_expanded() then
								text = nil
							end
						end
						icon.highlight = hl
						icon.text = text or icon.text
					end,
					default = "*",
					highlight = "NeoTreeFileIcon",
				},
				modified = {
					symbol = "[+]",
					highlight = "NeoTreeModified",
				},
				name = {
					trailing_slash = false,
					use_git_status_colors = true,
					highlight = "NeoTreeFileName",
				},
				git_status = {
					symbols = {
						added = "",
						modified = "",
						deleted = "✖",
						renamed = "󰁕",
						untracked = "",
						ignored = "",
						unstaged = "󰄱",
						staged = "",
						conflict = "",
					},
				},
			},
			window = {
				position = "left",
				width = 30,
				mapping_options = {
					noremap = true,
					nowait = true,
				},
				mappings = {
					["<space>"] = { "toggle_node", nowait = false },
					["<2-LeftMouse>"] = "open",
					["<cr>"] = "open",
					["<esc>"] = "cancel",
					["P"] = { "toggle_preview", config = { use_float = true, use_image_nvim = true } },
					["l"] = "focus_preview",
					["s"] = "split_with_window_picker",
					["S"] = "vsplit_with_window_picker",
					["t"] = "open_tabnew",
					["w"] = "open_with_window_picker",
					["C"] = "close_node",
					["a"] = { "add", config = { show_path = "none" } },
					["A"] = "add_directory",
					["d"] = "delete",
					["r"] = "rename",
					["b"] = "rename_basename",
					["y"] = "copy_to_clipboard",
					["x"] = "cut_to_clipboard",
					["p"] = "paste_from_clipboard",
					["c"] = "copy",
					["m"] = "move",
					["q"] = "close_window",
					["R"] = "refresh",
					["?"] = "show_help",
					["<"] = "prev_source",
					[">"] = "next_source",
					["i"] = "show_file_details",
					["O"] = { "open_with_oil", config = { title = "Open with Oil" } },
				},
			},
			nesting_rules = {},
			filesystem = {
				filtered_items = {
					visible = true,
					hide_dotfiles = false,
					hide_gitignored = true,
					hide_hidden = true,
					hide_by_name = { "node_modules" },
				},
				follow_current_file = {
					enabled = true,
					leave_dirs_open = false,
				},
				group_empty_dirs = false,
				hijack_netrw_behavior = "open_default",
				use_libuv_file_watcher = true,
				window = {
					mappings = {
						["<bs>"] = "navigate_up",
						["."] = "set_root",
						["H"] = "toggle_hidden",
						["/"] = "fuzzy_finder",
						["D"] = "fuzzy_finder_directory",
						["#"] = "fuzzy_sorter",
						["f"] = "filter_on_submit",
						["<c-x>"] = "clear_filter",
						["[g"] = "prev_git_modified",
						["]g"] = "next_git_modified",
						["o"] = { "show_help", nowait = false, config = { title = "Order by", prefix_key = "o" } },
						["oc"] = { "order_by_created", nowait = false },
						["od"] = { "order_by_diagnostics", nowait = false },
						["og"] = { "order_by_git_status", nowait = false },
						["om"] = { "order_by_modified", nowait = false },
						["on"] = { "order_by_name", nowait = false },
						["os"] = { "order_by_size", nowait = false },
						["ot"] = { "order_by_type", nowait = false },
					},
					fuzzy_finder_mappings = {
						["<down>"] = "move_cursor_down",
						["<C-n>"] = "move_cursor_down",
						["<up>"] = "move_cursor_up",
						["<C-p>"] = "move_cursor_up",
						["<esc>"] = "close",
					},
				},
			},
			buffers = {
				follow_current_file = {
					enabled = true,
					leave_dirs_open = false,
				},
				group_empty_dirs = true,
				show_unloaded = true,
				window = {
					mappings = {
						["d"] = "buffer_delete",
						["bd"] = "buffer_delete",
						["<bs>"] = "navigate_up",
						["."] = "set_root",
						["o"] = { "show_help", nowait = false, config = { title = "Order by", prefix_key = "o" } },
						["oc"] = { "order_by_created", nowait = false },
						["od"] = { "order_by_diagnostics", nowait = false },
						["om"] = { "order_by_modified", nowait = false },
						["on"] = { "order_by_name", nowait = false },
						["os"] = { "order_by_size", nowait = false },
						["ot"] = { "order_by_type", nowait = false },
					},
				},
			},
			commands = {
				---@param state NeotreeState
				open_with_oil = function(state)
					local node = state.tree:get_node()
					local path
					if node.type == "directory" then
						path = node.path
					elseif node.type == "file" then
						path = node:get_parent_id()
					else
						error("unknown neotree node type")
					end
					require("oil").open(path)
				end,
			},
			event_handlers = {
				{
					event = "file_opened",
					handler = function(_)
						require("neo-tree.command").execute({ action = "close" })
					end,
				},
			},
		},

		config = function(_, opts)
			require("neo-tree").setup(opts)

			vim.diagnostic.config({
				signs = {
					text = {
						[vim.diagnostic.severity.ERROR] = "",
						[vim.diagnostic.severity.WARN] = "",
						[vim.diagnostic.severity.INFO] = "",
						[vim.diagnostic.severity.HINT] = "󰄵",
					},
				},
			})
		end,
	},

	-- oil.nvim: kept alongside LazyVim neo-tree because it is useful for
	-- directory editing and has no LazyVim-equivalent alternative.
	{
		"stevearc/oil.nvim",
		enabled = lv_on("explorer"),
		---@module 'oil'
		---@type oil.SetupOpts
		opts = {},
		dependencies = {
			{ "echasnovski/mini.icons", opts = {} },
		},
		lazy = false,
	},
}
