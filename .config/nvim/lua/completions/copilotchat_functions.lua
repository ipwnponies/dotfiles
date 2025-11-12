local source = {}

--- @module 'blink.cmp'
--- @class blink.cmp.Source
function source:new(opts)
	local self = setmetatable({}, { __index = source })
	self.opts = opts
	return self
end

-- This source is only for CopilotChat
function source:enabled()
	return vim.bo.filetype == "copilot-chat"
end

function source:get_trigger_characters()
	return { "#" }
end

function source:should_show_items(ctx)
	local cursor = ctx.bounds.start_col
	local start_of_completion = ctx.line:sub(cursor - 2, cursor - 1)
	if #start_of_completion > 1 then
		-- Check word boundary. We only want completion for #.* standalone
		return start_of_completion:match("%W#")
	else
		-- Special edge case, start of line
		return start_of_completion == "#"
	end
end

local function add_open_buffer()
	local bufs = vim.api.nvim_list_bufs()
	local i = 0
	return function()
		while true do
			i = i + 1
			if i > #bufs then
				return nil
			end

			local bufnr = bufs[i]

			if vim.api.nvim_get_option_value("buflisted", { buf = bufnr }) then
				local bufname = vim.api.nvim_buf_get_name(bufnr)
				local relpath = vim.split(vim.fn.fnamemodify(bufname, ":."), "/")
				local display_path = (relpath[#relpath - 1] or "") .. "/" .. relpath[#relpath]
				return {
					label = "#buffer:" .. display_path,
					insertText = "#buffer:" .. bufnr,
					priority = 1,
				}
			end
		end
	end
end

function source:get_completions(ctx, callback)
	--- @type lsp.CompletionItem[]
	local items = {}

	local copilotchat_functions = {
		"#buffer",
		"#buffers:visible",
		"#diagnostics:current",
		"#file:",
		"#gitdiff:staged",
		"#gitstatus",
		"#glob:**/*.lua",
		"#grep:TODO",
		"#quickfix",
		"#register:+",
		"#selection",
		"#url:",
	}

	for _, func in ipairs(copilotchat_functions) do
		--- @type lsp.CompletionItem
		local item = {
			label = func,
			kind = require("blink.cmp.types").CompletionItemKind.Operator,
			documentation = "I love eaeting taco... TBD",
			insertTextFormat = vim.lsp.protocol.InsertTextFormat.PlainText,
		}
		table.insert(items, item)
	end

	for buf in add_open_buffer() do
		table.insert(items, buf)
	end

	callback({
		items = items,
		is_incomplete_backward = false,
		is_incomplete_forward = false,
	})
end

return source
