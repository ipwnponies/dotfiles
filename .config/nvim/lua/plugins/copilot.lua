-- Function to find existing Claude buffer
local preset_prompts = {
	{ name = "explain", prompt = "Please explain how this code works in detail." },
	{ name = "refactor", prompt = "Please refactor this code." },
	{ name = "bugs", prompt = "Please identify any bugs or issues in this code." },
	{ name = "test", prompt = "Please write tests for this line of code." },
	{ name = "analyze", prompt = "Please analyze this code." },
	{ name = "optimize", prompt = "Please optimize this code for performance." },
}

local AIController = {}
AIController.__index = AIController

function AIController.new(executable)
	return setmetatable({ executable = executable }, AIController)
end

function AIController:find_ai_buffer()
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_loaded(buf) then
			-- Claude has BufPostFile autocmd that updates the buffer name, so we can't set explicit name
			local buf_name = vim.api.nvim_buf_get_name(buf)
			local pattern = string.format("term://.*/%%d+:%s", self.executable)
			if string.find(buf_name, pattern .. "$") or string.find(buf_name, pattern .. "%W") then
				return buf
			end
		end
	end
	return nil
end

-- Function to find window containing a buffer
local function find_buffer_window(bufnr)
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		if vim.api.nvim_win_get_buf(win) == bufnr then
			return win
		end
	end
	return nil
end

-- Function to create or focus a Claude window
function AIController:create_or_focus_ai_window(bufnr)
	if not bufnr then
		-- Create a new scratch buffer
		bufnr = vim.api.nvim_create_buf(false, true)
		vim.cmd("vsplit")
		vim.api.nvim_win_set_buf(0, bufnr)

		vim.api.nvim_create_autocmd("WinEnter", {
			buffer = bufnr,
			callback = function(opts)
				local map_opts = { noremap = true, silent = true, buffer = opts.buf }
				vim.keymap.set("t", "<C-h>", [[<C-\\><C-n><C-w>h]], map_opts)
				vim.keymap.set("t", "<C-j>", [[<C-\\><C-n><C-w>j]], map_opts)
				vim.keymap.set("t", "<C-k>", [[<C-\\><C-n><C-w>k]], map_opts)
				vim.keymap.set("t", "<C-l>", [[<C-\\><C-n><C-w>l]], map_opts)
				vim.cmd("startinsert")
			end,
		})
		-- Open window with the buffer
		return vim.fn.termopen(self.executable), true
	end

	-- Try to find existing window with this buffer
	local winid = find_buffer_window(bufnr)
	if winid then
		-- Switch to the window
		-- Leave visual mode and enter terminal mode in new window
		vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
		vim.api.nvim_set_current_win(winid)
	else
		vim.cmd("vsplit")
		vim.api.nvim_win_set_buf(0, bufnr)
	end

	return vim.b[bufnr].terminal_job_id
end

-- Function to send selected text to Claude with a prompt
function AIController:send_selection_to_ai(prompt, range)
	local filename = vim.fn.expand("%:p")
	local line_number = range and string.format(":%d-%d", range.start, range.line_end) or ""
	local final_prompt = string.format("@%s%s\n%s", filename, line_number, prompt)

	-- Find existing Claude buffer or create new one
	local assistant_bufnr = self:find_ai_buffer()
	local job_id, is_created = self:create_or_focus_ai_window(assistant_bufnr)

	-- Ensure we're in insert mode for terminal interaction
	vim.cmd("startinsert")

	vim.defer_fn(function()
		vim.api.nvim_chan_send(job_id, final_prompt)
	end, is_created and 1000 or 0) -- No delay for existing terminal, 500ms for new one
end

-- Function to validate visual selection and execute Claude command
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
	local input_prompt = provider.input_prompt or string.format("Enter prompt for %s: ", prefix)
	local notify_level = provider.notify_level or vim.log.levels.INFO
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
					table.insert(preset_keys, "custom")

					local function run_prompt(choice)
						if not choice then
							return
						end
						if choice == "custom" then
							vim.ui.input({ prompt = input_prompt }, function(input)
								if input and input ~= "" then
									ai:execute(input, range)
								end
							end)
						else
							ai:execute(choice, range)
						end
					end

					vim.ui.select(preset_keys, { prompt = select_prompt }, run_prompt)
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
		},
		config = function()
			require("copilot").setup({})
			vim.api.nvim_create_autocmd("User", {
				pattern = "BlinkCmpMenuOpen",
				callback = function()
					vim.b.copilot_suggestion_hidden = true
				end,
			})

			vim.api.nvim_create_autocmd("User", {
				pattern = "BlinkCmpMenuClose",
				callback = function()
					vim.b.copilot_suggestion_hidden = false
				end,
			})
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
		dependencies = {
			"nvim-lua/plenary.nvim", -- Required for git operations
		},
		keys = {
			{
				"<leader>ck",
				"<cmd>ClaudeAsk<CR>",
				mode = "n",
				desc = "Send selection to Claude with custom prompt",
			},
			{
				"<leader>ck",
				":'<,'>ClaudeAsk<CR>",
				mode = "v",
				desc = "Send selection to Claude with custom prompt",
			},
		},
		config = function(_, opts)
			require("claude-code").setup(opts)
			register_ai_provider({
				prefix = "Claude",
				executable = "claude",
				list_header = "Available Claude Presets:",
				select_prompt = "Select a preset prompt or enter custom (Claude):",
				input_prompt = "Enter prompt for Claude: ",
			})
		end,
	},
	{
		"johnseth97/codex.nvim",
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
			"CodexListPresets",
		},
		keys = {
			{
				"<leader>cd",
				function()
					require("codex").toggle()
				end,
				desc = "Toggle Codex popup",
			},
			{
				"<leader>cx",
				"<cmd>CodexAsk<CR>",
				mode = "n",
				desc = "Send selection to Codex with custom prompt",
			},
			{
				"<leader>cx",
				":'<,'>CodexAsk<CR>",
				mode = "v",
				desc = "Send selection to Codex with custom prompt",
			},
		},
		opts = {
			keymaps = {
				toggle = nil, -- Keybind to toggle Codex window (Disabled by default, watch out for conflicts)
				quit = "<C-q>", -- Keybind to close the Codex window (default: Ctrl + q)
			}, -- Disable internal default keymap (<leader>cc -> :CodexToggle)
			border = "rounded", -- Options: 'single', 'double', or 'rounded'
			width = 0.8, -- Width of the floating window (0.0 to 1.0)
			height = 0.8, -- Height of the floating window (0.0 to 1.0)
			model = nil, -- Optional: pass a string to use a specific model (e.g., 'o3-mini')
			autoinstall = true, -- Automatically install the Codex CLI if not found
		},
		config = function(_, opts)
			require("codex").setup(opts)

			register_ai_provider({
				prefix = "Codex",
				executable = "codex",
				list_header = "Available Codex Presets:",
				select_prompt = "Select a preset prompt or enter custom (Codex):",
				input_prompt = "Enter prompt for Codex: ",
			})
		end,
	},
}
