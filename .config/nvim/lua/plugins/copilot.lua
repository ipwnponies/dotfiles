-- Function to get visual selection
local function get_visual_selection()
	local start_pos = vim.fn.getpos("'<")
	local end_pos = vim.fn.getpos("'>")

	-- Ensure we're dealing with a visual selection
	if start_pos[2] == 0 or end_pos[2] == 0 then
		return nil
	end

	local line_start = start_pos[2]
	local line_end = end_pos[2]

	-- Get the filename to provide context
	local filename = vim.fn.expand("%:p")

	-- Return selection information
	return {
		filename = filename,
		line_start = line_start,
		line_end = line_end,
	}
end

-- Function to find existing Claude buffer
local function find_claude_buffer()
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_loaded(buf) then
			-- Claude has BufPostFile autocmd that updates the buffer name, so we can't set explicit name
			if string.find(vim.api.nvim_buf_get_name(buf), "term://.*/%d+:claude .*", 1, false) then
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
		return nil
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
local function send_selection_to_claude(prompt)
	local selection = get_visual_selection()
	if not selection then
		vim.notify("No visual selection detected", vim.log.levels.ERROR)
		return
	end

	local text_with_context =
		string.format("From file %s (lines %d-%d)", selection.filename, selection.line_start, selection.line_end)

	local claude_bufnr = find_claude_buffer()
	local job_id = create_or_focus_claude_window(claude_bufnr)

	if job_id then
		-- Send to existing terminal, type into claude TUI prompt
		vim.api.nvim_chan_send(job_id, text_with_context .. prompt)
	else
		-- Start the terminal with Claude command
		local escaped_text = vim.fn.shellescape(text_with_context)

		local claude_command = string.format('claude "%s %s"', vim.fn.shellescape(escaped_text), prompt)
		vim.fn.termopen(claude_command)
	end

	vim.cmd("startinsert")
end

-- Function to validate visual selection and execute Claude command
local function execute_claude_command(prompt, opts)
	-- Check mode to ensure we have a visual selection
	if not (opts.range > 0) then
		vim.notify("This command requires a visual selection", vim.log.levels.WARN)
		return
	end

	-- Sanitize prompt if provided
	if prompt and type(prompt) == "string" then
		-- Ensure prompt ends with a space for better formatting
		if not prompt:match("s$") then
			prompt = prompt .. " "
		end
		-- Execute with validated prompt
		pcall(send_selection_to_claude, prompt)
	else
		vim.notify("Invalid prompt format", vim.log.levels.ERROR)
	end
end

---@module 'lazy'
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
		config = function()
			require("CopilotChat").setup({
				system_prompt = "my_system_prompt",
				prompts = {
					my_system_prompt = {
						system_prompt = require("CopilotChat.config.prompts").COPILOT_BASE.system_prompt
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
							]],
						description = "Custom prompt for brevity and stylistic preference. And anti-sycophancy tendencies",
					},
				},
			})
			vim.g.copilot_no_tab_map = true
		end,
	},
	{
		"greggh/claude-code.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim", -- Required for git operations
		},
		config = function()
			require("claude-code").setup()

			-- Command to send selection to Claude with a prompt
			vim.api.nvim_create_user_command("ClaudeRefactor", function(opts)
				execute_claude_command("Please refactor this code:", opts)
			end, {
				range = true,
				desc = "Send selection to Claude for refactoring",
			})

			-- Command with custom prompt
			vim.api.nvim_create_user_command("ClaudeAsk", function(opts)
				if opts.args ~= "" then
					-- Use the provided argument as prompt
					execute_claude_command(opts.args, opts)
				else
					-- Prompt user interactively for input
					vim.ui.input({
						prompt = "Enter prompt for Claude: ",
						default = "Please analyze this code: ",
					}, function(input)
						if input then
							execute_claude_command(input, opts)
						end
					end)
				end
			end, {
				range = true,
				nargs = "?",
				desc = "Send selection to Claude with custom prompt",
			})

			vim.keymap.set(
				"v",
				"<leader>ck",
				":ClaudeAsk<CR>",
				{ desc = "Send selection to Claude with custom prompt" }
			)
		end,
	},
}
