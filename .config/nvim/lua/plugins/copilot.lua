-- Function to find existing Claude buffer
local preset_prompts = {
	{ name = "Custom", prompt = "" },
	{ name = "Explain", prompt = "Explain in detail how this code works, step by step." },
	{ name = "Refactor", prompt = "Refactor this code to improve readability or structure." },
	{ name = "Bugs", prompt = "Identify any bugs or issues in this code." },
	{ name = "Test", prompt = "Write tests for this code." },
	{ name = "Analyze", prompt = "Analyze this code for quality, design, and potential improvements." },
	{ name = "Optimize", prompt = "Optimize this code for better performance." },
	{ name = "Feature", prompt = "Add an awesome new feature, which" },
}

local plugin_window_openers = {
	claude = function()
		require("claude-code").toggle()
	end,
	codex = function()
		require("codex").toggle()
	end,
}

-- Override coding agent by environment
-- top priority is .nvim.lua (exrc)
-- then env var
-- then fallback to codex
local coding_agent = vim.g.coding_agent_preference or vim.env.CODING_AGENT_PREFERENCE or "codex"

local function ai_keymaps(command_prefix)
	local ask_desc = "Send selection to coding agent with custom prompt"
	local toggle_mapping
	toggle_mapping = {
		"<m-,>",
		function()
			if command_prefix == "Codex" then
				plugin_window_openers.codex()
				local win = require("codex.state").win
				-- Only enter insert model if window is open
				if win ~= nil and vim.api.nvim_win_is_valid(win) then
					vim.cmd("startinsert")
				end
			else
				-- Claude has toggle with insert mode already
			end
		end,
		mode = { "n", "t" },
		desc = "Toggle coding agent popup",
	}

	return {
		toggle_mapping,
		{
			"<leader>ck",
			string.format("<cmd>%sAsk<CR>", command_prefix),
			mode = "n",
			desc = ask_desc,
		},
		{
			"<leader>ck",
			string.format(":'<,'>%sAsk<CR>", command_prefix),
			mode = "v",
			desc = ask_desc,
		},
	}
end

local AIController = {}
AIController.__index = AIController

function AIController.new(executable)
	return setmetatable({ executable = executable }, AIController)
end

function AIController:find_ai_buffer()
	if self.executable == "claude" then
		local claude = require("claude-code").claude_code

		return claude.instances[claude.current_instance]
	elseif self.executable == "codex" then
		for _, buf in ipairs(vim.api.nvim_list_bufs()) do
			if vim.api.nvim_buf_is_loaded(buf) then
				local buftype = vim.api.nvim_get_option_value("buftype", { buf = buf })
				if buftype == "terminal" then
					local filetype = vim.api.nvim_get_option_value("filetype", { buf = buf })
					if self.executable == "codex" and filetype == "codex" then
						return buf
					end
				end
			end
		end
	end
	return nil
end

-- Function to find window containing a buffer
local function find_buffer_window(bufnr)
	-- win_findbuf also reports floating windows so popups like Codex/Claude are detected
	local wins = vim.fn.win_findbuf(bufnr)
	for _, win in ipairs(wins) do
		if vim.api.nvim_win_is_valid(win) then
			return win
		end
	end

	return nil
end

-- Function to create or focus a coding agent window
function AIController:create_or_focus_ai_window(bufnr)
	local created_new_instance = false
	local launcher = plugin_window_openers[self.executable]

	if not launcher then
		error("No launcher defined for executable: " .. self.executable)
	end

	local always_insert_mode_autocmd = function()
		vim.api.nvim_create_autocmd({ "BufWinEnter" }, {
			group = vim.api.nvim_create_augroup("AgentTerminalAutoInsertGroup", { clear = true }),
			buffer = bufnr,
			callback = function()
				vim.defer_fn(function()
					vim.cmd("startinsert")
				end, 5)
			end,
		})
	end

	-- Create buffer if not exist
	if not bufnr then
		launcher()
		bufnr = self:find_ai_buffer()
		created_new_instance = true

		always_insert_mode_autocmd()
	end

	local winid = find_buffer_window(bufnr)

	-- Buffer is not currently displayed
	if not winid then
		launcher()
		winid = find_buffer_window(bufnr)
		always_insert_mode_autocmd()
	end

	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
	vim.api.nvim_set_current_win(winid)
	return vim.b[bufnr].terminal_job_id, created_new_instance
end

-- Function to send selected text to coding agent with a prompt
function AIController:send_selection_to_ai(prompt, range)
	local filename = vim.fn.expand("%:p")
	local line_number = range and string.format(":%d-%d", range.start, range.line_end) or ""
	local final_prompt = string.format("@%s%s\n%s", filename, line_number, prompt)

	-- Find existing coding agent buffer or create new one
	local assistant_bufnr = self:find_ai_buffer()
	local job_id, is_created = self:create_or_focus_ai_window(assistant_bufnr)

	vim.defer_fn(function()
		vim.api.nvim_chan_send(job_id, final_prompt)
	end, is_created and 1000 or 0) -- No delay for existing terminal, 500ms for new one
end

-- Function to validate visual selection and execute coding agent command
-- Expand abbreviated prompt if it's a preset name
function AIController:execute(prompt, range)
	local prompt_text = prompt
	for _, preset_entry in ipairs(preset_prompts) do
		if preset_entry.name == prompt then
			prompt_text = preset_entry.prompt
			break
		end
	end

	-- Ensure prompt ends with a space for better formatting
	if not prompt_text:match("s$") then
		prompt_text = prompt_text .. " "
	end

	pcall(function()
		self:send_selection_to_ai(prompt_text, range)
	end)
end

-- Helper to register commands and preset tooling for a terminal-based AI assistant
local function register_ai_provider(provider)
	local prefix = provider.prefix
	local executable = provider.executable
	local list_header = provider.list_header or string.format("Available %s Presets:", prefix)
	local select_prompt = provider.select_prompt or "Select a preset prompt or enter custom:"
	local ai = AIController.new(executable, provider.window)

	vim.api.nvim_create_user_command(prefix .. "ListPresets", function()
		local lines = { list_header }
		table.insert(lines, string.rep("-", 25))
		for _, preset in ipairs(preset_prompts) do
			table.insert(lines, string.format("%-12s %s", preset.name .. ":", preset.prompt))
		end
	end, {})

	local function register_command(name, preset, command_opts)
		command_opts = command_opts or {}
		local nargs = command_opts.nargs or "?"

		vim.api.nvim_create_user_command(prefix .. name, function(opts)
			local range
			if opts.range == 2 then
				range = { start = opts.line1, line_end = opts.line2 }
			end

			if name == "Ask" then
				if opts.args ~= "" then
					ai:execute(opts.args, range)
				else
					local preset_keys = {}
					for _, preset_entry in ipairs(preset_prompts) do
						table.insert(preset_keys, preset_entry.name)
					end

					require("fzf-lua").fzf_exec(preset_keys, {
						prompt = select_prompt,
						actions = {
							["default"] = function(selected)
								ai:execute(selected[1], range)
							end,
						},
					})
				end
			else
				ai:execute(preset, range)
			end
		end, { range = 0, nargs = nargs })
	end

	register_command("Ask", nil, { nargs = "?" })
	register_command("Refactor", "refactor")
	register_command("Analyze", "analyze")
	register_command("Optimize", "optimize")
	register_command("Explain", "explain")
	register_command("Bugs", "bugs")
	register_command("Test", "test")
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
		keys = ai_keymaps("Claude"),
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
			register_ai_provider({
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
		keys = ai_keymaps("Codex"),
		opts = {
			border = "rounded",
			width = 0.8,
			height = 0.8,
			model = nil,
			autoinstall = false,
		},
		config = function(_, opts)
			require("codex").setup(opts)

			register_ai_provider({
				prefix = "Codex",
				executable = "codex",
				list_header = "Available Codex Presets:",
				select_prompt = "Select a preset prompt or enter custom (Codex):",
			})
		end,
	},
}
