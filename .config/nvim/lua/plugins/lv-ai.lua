-- LazyVim-equivalent AI stack, active when vim.g.lv.ai = true.
--
-- ┌─ TRADE-OFF NOTICE ────────────────────────────────────────────────────┐
-- │ Enabling lv.ai = true activates the standard LazyVim copilot.lua stack      │
-- │ (GitHub Copilot backend + CopilotChat) and DISABLES the custom multi-agent  │
-- │ switch in copilot.lua (claude-code.nvim / codex.nvim / codecompanion).      │
-- │                                                                              │
-- │ The three-way coding_agent_preference switch (claude / codex / copilot)     │
-- │ has no LazyVim equivalent and is a valuable differentiator — it is          │
-- │ intentionally preserved in copilot.lua for as long as lv.ai = false.        │
-- │                                                                              │
-- │ Only promote lv.ai = true if you no longer need the multi-agent switch.     │
-- └────────────────────────────────────────────────────────────────────────────┘

---@type LazyPluginSpec[]
return {
	{
		-- copilot.lua: GitHub Copilot backend (completions surface via blink-copilot only).
		"zbirenbaum/copilot.lua",
		enabled = lv_on("ai"),
		cmd = "Copilot",
		event = "InsertEnter",
		opts = {
			panel = { enabled = false },
			suggestion = {
				enabled = false, -- Blink is the only suggestion UI/trigger path; avoid duplicate inline suggestion engine work.
			},
			filetypes = {
				markdown = true,
				help = true,
			},
		},
		config = function(_, opts)
			require("copilot").setup(opts)
		end,
	},
	{
		-- CopilotChat: interactive AI chat with GitHub Copilot.
		"CopilotC-Nvim/CopilotChat.nvim",
		enabled = lv_on("ai"),
		cmd = vim.tbl_map(function(name)
			return "CopilotChat" .. name
		end, {
			"",
			"Docs",
			"Explain",
			"Fix",
			"Optimize",
			"Review",
			"Tests",
			"Prompts",
		}),
		dependencies = {
			{ "nvim-lua/plenary.nvim", branch = "master" },
			"zbirenbaum/copilot.lua",
		},
		keys = {
			{
				"<M-l>",
				function()
					return vim.fn["copilot#Accept"]("\\<CR>")
				end,
				mode = "i",
				expr = true,
				silent = true,
				replace_keycodes = false,
			},
			{ "<leader>cc", "<cmd>CopilotChat<cr>", mode = { "n", "v" }, silent = true },
			{ "<leader>ce", "<cmd>CopilotChatExplain<cr>", mode = { "n", "v" }, silent = true },
			{ "<leader>cf", "<cmd>CopilotChatFix<cr>", mode = { "n", "v" }, silent = true },
		},
		opts = {
			window = {
				layout = "float",
				width = 0.5,
				relative = "win",
			},
			chat_autocomplete = false,
			-- Use visual selection, fallback to current buffer
			selection = function(source)
				return require("CopilotChat.select").visual(source) or require("CopilotChat.select").buffer(source)
			end,
		},
		config = function(_, opts)
			require("CopilotChat").setup(opts)
		end,
	},
}
