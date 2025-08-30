-- Function to find existing Claude buffer
local function find_claude_buffer()
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_loaded(buf) then
			-- Claude has BufPostFile autocmd that updates the buffer name, so we can't set explicit name
			local buf_name = vim.api.nvim_buf_get_name(buf)
			local pattern = "term://.*/%d+:claude"
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
local function create_or_focus_claude_window(bufnr)
	if not bufnr then
		-- Create a new scratch buffer
		bufnr = vim.api.nvim_create_buf(false, true)
		vim.cmd("vsplit")
		vim.api.nvim_win_set_buf(0, bufnr)

		vim.api.nvim_create_autocmd("WinEnter", {
			buffer = bufnr,
			callback = function(opts)
				local map_opts = { noremap = true, silent = true, buffer = opts.buf }
				vim.keymap.set("t", "<C-h>", [[<C-\><C-n><C-w>h]], map_opts)
				vim.keymap.set("t", "<C-j>", [[<C-\><C-n><C-w>j]], map_opts)
				vim.keymap.set("t", "<C-k>", [[<C-\><C-n><C-w>k]], map_opts)
				vim.keymap.set("t", "<C-l>", [[<C-\><C-n><C-w>l]], map_opts)
				vim.cmd("startinsert")
			end,
		})
		return vim.fn.termopen("claude"), true
	else
		-- Try to find existing window with this buffer
		local winid = find_buffer_window(bufnr)

		if winid then
			-- Switch to the window
			vim.api.nvim_set_current_win(winid)
		else
			-- Open window with the buffer
			vim.cmd("vsplit")
			vim.api.nvim_win_set_buf(0, bufnr)
		end

		return vim.b[bufnr].terminal_job_id
	end
end

-- Function to send selected text to Claude with a prompt
local function send_selection_to_claude(prompt, range)
	local filename = vim.fn.expand("%:p")
	local line_number = range and string.format(":%d-%d", range.start, range.line_end) or ""
	local final_prompt = string.format("@%s%s\n%s", filename, line_number, prompt)

	-- Find existing Claude buffer or create new one
	local claude_bufnr = find_claude_buffer()
	local job_id, is_created = create_or_focus_claude_window(claude_bufnr)

	-- Ensure we're in insert mode for terminal interaction
	vim.cmd("startinsert")

	vim.defer_fn(function()
		vim.api.nvim_chan_send(job_id, final_prompt)
	end, is_created and 1000 or 0) -- No delay for existing terminal, 500ms for new one
end

local preset_prompts = {
	{ name = "explain", prompt = "Please explain how this code works in detail." },
	{ name = "refactor", prompt = "Please refactor this code." },
	{ name = "bugs", prompt = "Please identify any bugs or issues in this code." },
	{ name = "test", prompt = "Please write tests for this code." },
	{ name = "analyze", prompt = "Please analyze this code." },
	{ name = "optimize", prompt = "Please optimize this code for performance." },
}

-- Function to validate visual selection and execute Claude command
local function execute_claude_command(prompt, range)
	-- Expand abbreviated prompt if it's a preset name
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

	pcall(send_selection_to_claude, prompt_text, range)
end

---@type LazyPluginSpec | LazyPluginSpec[]
return {
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
		}),
		dependencies = {
			{ "github/copilot.vim", build = ":Copilot setup" }, -- or zbirenbaum/copilot.lua
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
			},
			-- Use visual selection, fallback to current line
			selection = function(source)
				return require("CopilotChat.select").visual(source) or require("CopilotChat.select").buffer(source)
			end,
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

			vim.g.copilot_no_tab_map = true
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
		config = function()
			require("claude-code").setup()

			-- Register command to list available Claude presets
			vim.api.nvim_create_user_command("ClaudeListPresets", function()
				local lines = { "Available Claude Presets:" }
				table.insert(lines, string.rep("-", 25))
				for _, preset in ipairs(preset_prompts) do
					table.insert(lines, string.format("%-12s %s", preset.name .. ":", preset.prompt))
				end
				vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO)
			end, {})

			-- Helper function to register Claude commands
			local function register_claude_command(name, preset, config)
				config = config or {}
				local nargs = config.nargs or "?"

				vim.api.nvim_create_user_command("Claude" .. name, function(opts)
					local range
					-- Only applicable for range Command
					if opts.range == 2 then
						range = { start = opts.line1, line_end = opts.line2 }
					end
					-- Handle custom prompt input for ClaudeAsk
					if name == "Ask" then
						if opts.args ~= "" then
							execute_claude_command(opts.args, range)
						else
							local preset_keys = {}
							for _, preset in ipairs(preset_prompts) do
								table.insert(preset_keys, preset.name)
							end
							table.insert(preset_keys, "custom")

							-- Noop if no prompt
							local execute_claude_command_callback = function(prompt)
								if prompt then
									execute_claude_command(prompt, range)
								end
							end
							vim.ui.select(preset_keys, {
								prompt = "Select a preset prompt or enter custom:",
							}, function(choice)
								if choice == "custom" then
									vim.ui.input({
										prompt = "Enter prompt for Claude: ",
									}, execute_claude_command_callback)
								else
									execute_claude_command_callback(choice)
								end
							end)
						end
					else
						-- For preset commands, just execute with the preset
						execute_claude_command(preset, range)
					end
				end, { range = 0, nargs = nargs })
			end

			-- Register all Claude commands with consistent configuration
			register_claude_command("Ask", nil, { nargs = "?" })
			register_claude_command("Refactor", "refactor")
			register_claude_command("Analyze", "analyze")
			register_claude_command("Optimize", "optimize")
			register_claude_command("Explain", "explain")
			register_claude_command("Bugs", "bugs")
			register_claude_command("Test", "test")
		end,
	},
}
