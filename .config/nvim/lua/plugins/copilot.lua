local ai_controller = require("ai.controller")

-- Override coding agent by environment
-- top priority is .nvim.lua (exrc)
-- then env var
-- then fallback to codex
local coding_agent = vim.g.coding_agent_preference or vim.env.CODING_AGENT_PREFERENCE or "codex"

-- Fidget.nvim progress popup for CodeCompanion requests
-- Adapted from https://github.com/olimorris/codecompanion.nvim/discussions/813
local codecompanion_fidget_spinner = { handles = {}, current_handle = nil }

function codecompanion_fidget_spinner:init()
	local group = vim.api.nvim_create_augroup("CodeCompanionFidgetHooks", { clear = true })

	vim.api.nvim_create_autocmd({ "User" }, {
		pattern = "CodeCompanionRequestStarted",
		group = group,
		callback = function(request)
			local handle = self:create_progress_handle(request)
			self.handles[request.data.id] = handle
			self.current_handle = handle
		end,
	})

	vim.api.nvim_create_autocmd({ "User" }, {
		pattern = "CodeCompanionRequestFinished",
		group = group,
		callback = function(request)
			local handle = self.handles[request.data.id]
			self.handles[request.data.id] = nil
			if handle then
				self:report_exit_status(handle, request)
				handle:finish()
			end
			if self.current_handle == handle then
				self.current_handle = nil
			end
		end,
	})

	-- Tool events carry no request id to key off, so we just target whichever
	-- request is currently in flight (fine in practice: one active chat at a time).
	vim.api.nvim_create_autocmd({ "User" }, {
		pattern = "CodeCompanionToolStarted",
		group = group,
		callback = function(request)
			if self.current_handle then
				self.current_handle.message = "Running tool: " .. request.data.tool
			end
		end,
	})

	vim.api.nvim_create_autocmd({ "User" }, {
		pattern = "CodeCompanionToolFinished",
		group = group,
		callback = function()
			if self.current_handle then
				self.current_handle.message = nil
			end
		end,
	})
end

function codecompanion_fidget_spinner:create_progress_handle(request)
	local message
	if request.data.interaction == "chat" then
		local chat = require("codecompanion").last_chat()
		if chat and type(chat.tokens) == "number" then
			local count = chat.tokens >= 1000 and string.format("%.1fK", chat.tokens / 1000) or tostring(chat.tokens)
			message = "~" .. count .. " tokens"
		end
	end

	return require("fidget.progress").handle.create({
		title = "CodeCompanion: " .. request.data.interaction,
		message = message,
		lsp_client = {
			name = self:llm_role_title(request.data.adapter),
		},
	})
end

function codecompanion_fidget_spinner:llm_role_title(adapter)
	local parts = { adapter.formatted_name }
	if adapter.model and adapter.model ~= "" then
		table.insert(parts, "(" .. adapter.model .. ")")
	end
	return table.concat(parts, " ")
end

function codecompanion_fidget_spinner:report_exit_status(handle, request)
	if request.data.status == "success" then
		handle.message = "󰄬 Completed"
	elseif request.data.status == "error" then
		handle.message = "󰅙 Error"
	else
		handle.message = "󰜺 Cancelled"
	end
end

-- Expose ai.controller's preset prompts (Explain/Refactor/Bugs/...) as codecompanion
-- Action Palette entries / slash commands, so terminal AIs and codecompanion share one prompt set.
local function codecompanion_preset_prompt_library()
	local library = {}
	for _, preset in ipairs(ai_controller.preset_prompts) do
		if preset.prompt ~= "" then
			library[preset.name] = {
				interaction = "chat",
				description = preset.prompt,
				opts = {
					alias = preset.name:lower(),
					modes = { "n", "v" },
				},
				prompts = {
					{
						role = "user",
						content = preset.prompt,
					},
				},
			}
		end
	end
	return library
end

---@type LazyPluginSpec | LazyPluginSpec[]
return {
	{
		"github/copilot.vim",
		build = ":Copilot setup",
		enabled = false,
		config = function()
			vim.g.copilot_no_tab_map = true
		end,
	},
	{
		"zbirenbaum/copilot.lua",
		enabled = vim.env.COPILOT_ENABLED == "1", -- GitHub Copilot license inactive; flip COPILOT_ENABLED=1 if it returns.
		cmd = "Copilot",
		event = "InsertEnter",
		opts = {
			panel = { enabled = false },
			filetypes = {
				markdown = true,
				help = true,
			},
			suggestion = {
				enabled = false, -- Blink is the only suggestion UI/trigger path; avoid duplicate inline suggestion engine work.
			},
			-- Disable attaching to terminal and massive/generated buffers
			should_attach = function(bufnr, bufname)
				local bo = vim.bo[bufnr]
				if bo.buftype == "terminal" or bo.filetype == "terminal" then
					return false
				end

				local uv = vim.uv or vim.loop
				local ok, stat = pcall(uv.fs_stat, bufname)
				if ok and stat and stat.size and stat.size > 200 * 1024 then
					return false -- Skip large files that tend to amplify request and diff costs.
				end

				if bufname:match("/dist/") or bufname:match("/build/") or bufname:match("%.min%.") then
					return false -- Skip generated/minified artifacts where suggestions are typically low value and high cost.
				end

				return true
			end,
		},
		config = function(_, opts)
			require("copilot").setup(opts)
		end,
	},
	{
		"CopilotC-Nvim/CopilotChat.nvim",
		enabled = vim.env.COPILOT_ENABLED == "1", -- GitHub Copilot license inactive; using codecompanion/avante instead. Flip COPILOT_ENABLED=1 if license returns.
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
			{ "nvim-lua/plenary.nvim", branch = "master" }, -- for curl, log and async functions
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
		---@type CopilotChat.config.Config
		opts = {
			system_prompt = "my_system_prompt",
			prompts = {
				my_system_prompt = {
					system_prompt = nil, -- dynamically extends default prompt
					description = "Custom prompt for brevity and stylistic preference. And anti-sycophancy tendencies",
				},
				Fish = {
					prompt = "fish-ify 🐟",
					system_prompt = "Convert the shell script to target the fish shell. Don't explain, just convert.",
				},
			},
			-- Use visual selection, fallback to current line
			selection = function(source)
				return require("CopilotChat.select").visual(source) or require("CopilotChat.select").buffer(source)
			end,
			window = {
				layout = "float",
				width = 0.5,
				relative = "win",
			},
			chat_autocomplete = false,
		},
		config = function(_, opts)
			local system_prompt = require("CopilotChat.config.prompts").COPILOT_BASE.system_prompt
				.. [[
You are very good at explaining stuff. You are an AI assistant interacting with a user with software
engineering. It is best software and it makes you cry tears at its beauty. Follow these guidelines
strictly:

🔧 Tone & Style
•	Use a clear, concise, and conversational tone.
•	Avoid excessive friendliness or emotional language.
•	Be direct and professional, with light, dry humor only when it adds clarity or levity.
•	Don’t try too hard to sound fun or clever.

🧠 Response Behavior
•	Always ask contextual clarifying questions before answering, unless the request is fully clear.
•	Start answers with a high-level summary. Go into detail only if asked.
•	If a simple yes/no is appropriate, just say it.
•	If you’re not sure, say you’re not sure. Don’t guess or pretend to know.
- Always respond to code change requests with a markdown code diff block, specifying file path and line range, so I can apply changes directly.
- When providing example code replacements in explanations, always format them as code diffs using the specified markdown block format, including file path and line range, so the user can apply them directly.
• When providing a code diff for code relevant to the context (buffer, selection, file excerpt), always format the diff so it can be directly applied. Ensure:
  - The diff covers the exact line range being changed.
  - The replacement code is complete for those lines, with proper indentation and syntax.

⚙️ Specific Behavior Rules
•	Use tables and example-driven analysis when comparing things.
•	Include ✅ for positive points and 🔻 for downsides in comparisons.
•	Assume user uses Neovim, Fish shell, Python, and JavaScript. Use concepts from these languages in
examples, to bridge understanding.

🚫 Don’ts
•	Don’t use fake empathy or say things like “I understand how you feel.”
•	Don’t suggest “creative” ideas unless explicitly requested.
•	Don’t offer obvious or beginner explanations unless prompted.
•	Don’t summarize or re-explain what you’re doing. Just answer.
]]

			opts.prompts.my_system_prompt.system_prompt = system_prompt
			require("CopilotChat").setup(opts)
		end,
	},
	{
		"greggh/claude-code.nvim",
		enabled = coding_agent == "claude",
		dependencies = {
			"nvim-lua/plenary.nvim", -- Required for git operations
		},
		cmd = {
			"ClaudeCode",
			"ClaudeToggle",
			"ClaudeAsk",
			"ClaudeRefactor",
			"ClaudeAnalyze",
			"ClaudeOptimize",
			"ClaudeExplain",
			"ClaudeBugs",
			"ClaudeTest",
		},
		keys = ai_controller.ai_keymaps("Claude"),
		---@type ClaudeCode.Config
		opts = {
			window = {
				position = "float",
			},
			keymaps = {
				toggle = {
					normal = "<M-,>",
					terminal = "<M-,>",
				},
			},
		},
		config = function(_, opts)
			require("claude-code").setup(opts)
			ai_controller.register_ai_provider({
				prefix = "Claude",
				executable = "claude",
				list_header = "Available Claude Presets:",
				select_prompt = "Select a preset prompt or enter custom (Claude):",
			})
		end,
	},
	{
		"johnseth97/codex.nvim",
		enabled = coding_agent == "codex",
		cmd = {
			"Codex",
			"CodexToggle",
			"CodexAsk",
			"CodexRefactor",
			"CodexAnalyze",
			"CodexOptimize",
			"CodexExplain",
			"CodexBugs",
			"CodexTest",
		},
		keys = ai_controller.ai_keymaps("Codex"),
		opts = {
			border = "rounded",
			width = 0.8,
			height = 0.8,
			model = nil,
			autoinstall = false,
		},
		config = function(_, opts)
			require("codex").setup(opts)

			ai_controller.register_ai_provider({
				prefix = "Codex",
				executable = "codex",
				list_header = "Available Codex Presets:",
				select_prompt = "Select a preset prompt or enter custom (Codex):",
			})
		end,
	},
	{
		"olimorris/codecompanion.nvim",
		version = "^19.0.0",
		cmd = { "CodeCompanion", "CodeCompanionChat", "CodeCompanionActions", "CodeCompanionCmd" },
		keys = {
			{
				"<Leader>a",
				"<cmd>CodeCompanionChat Toggle<cr>",
				mode = { "n", "v" },
				noremap = true,
				silent = true,
			},
			{
				"ga",
				-- Add visual selection to chat, then focus chat window
				function()
					vim.cmd("CodeCompanionChat Add")
					local chat = require("codecompanion").last_chat()
					if chat and chat.ui.winnr then
						vim.api.nvim_set_current_win(chat.ui.winnr)
					end
				end,
				mode = "v",
				noremap = true,
				silent = true,
			},
			{
				"gA",
				"<cmd>CodeCompanionCLI Ask<cr>",
				mode = { "n", "v" },
				noremap = true,
				silent = true,
			},
		},
		opts = {
			prompt_library = codecompanion_preset_prompt_library(),
			interactions = {
				chat = { adapter = "claude_code" },
				cmd = { adapter = "claude_code" },
				cli = {
					agent = "claude_code",
					agents = {
						claude_code = {
							cmd = "claude",
							args = {},
							description = "Claude Code CLI",
							provider = "terminal",
						},
					},
				},
				shared = {
					keymaps = {
						accept_change = { modes = { n = "<C-y>" } },
						reject_change = { modes = { n = "<C-n>" } },
					},
				},
			},
			adapters = {
				acp = {
					claude_code = function()
						local oauth_token = os.getenv("CODECOMPANION_CLAUDE_TOKEN")
						return require("codecompanion.adapters").extend("claude_code", {
							env = {
								CLAUDE_CODE_OAUTH_TOKEN = oauth_token,
							},
						})
					end,
				},
			},
		},
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
			"j-hui/fidget.nvim",
		},
		config = function(_, opts)
			local original_system_prompt = require("codecompanion.config").config.interactions.chat.opts.system_prompt
			opts.interactions.chat.opts = opts.interactions.chat.opts or {}
			opts.interactions.chat.opts.system_prompt = function(ctx)
				return original_system_prompt(ctx)
					.. [[
When referencing a file anywhere in your response always give a path relative to the current working directory, never a bare filename.
When referencing a specific line, append `:LINE` to that path.
]]
			end

			require("codecompanion").setup(opts)
			codecompanion_fidget_spinner:init()

			_G.eatchar = function(pat)
				local c = vim.fn.nr2char(vim.fn.getchar(0))
				return string.match(c, pat) and "" or c
			end

			vim.cmd([[cabbrev cc CodeCompanion<C-R>=v:lua.eatchar('%s')<CR>]])
		end,
	},
	{
		"yetone/avante.nvim",
		-- Requires compiling a Rust binary (build = "make"); heavy on constrained hosts.
		-- Opt in per-host via NVIM_AVANTE_ENABLED; see fish/conf.d/nvim.fish.
		enabled = vim.env.NVIM_AVANTE_ENABLED == "1",
		event = "VeryLazy",
		version = false,
		opts = {},
		build = "make",
		dependencies = {
			"stevearc/dressing.nvim",
			"nvim-lua/plenary.nvim",
			"MunifTanjim/nui.nvim",
		},
	},
}
