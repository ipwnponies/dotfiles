local preset_prompts = {
	{ name = "Custom", prompt = "" },
	{ name = "Explain", prompt = "Explain in detail how this code works, step by step." },
	{ name = "Refactor", prompt = "Refactor this code to improve readability or structure." },
	{ name = "Bugs", prompt = "Identify any bugs or issues in this code." },
	{ name = "Test", prompt = "Write tests for this code." },
	{ name = "Analyze", prompt = "Analyze this code for quality, design, and potential improvements." },
	{ name = "Optimize", prompt = "Optimize this code for better performance." },
	{ name = "Implement", prompt = "Implement this code." },
}

local plugin_window_openers = {
	claude = function()
		require("claude-code").toggle()
	end,
	codex = function()
		require("codex").toggle()
	end,
}

local M = {}

M.preset_prompts = preset_prompts

function M.ai_keymaps(command_prefix)
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
function M.register_ai_provider(provider)
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

return M
