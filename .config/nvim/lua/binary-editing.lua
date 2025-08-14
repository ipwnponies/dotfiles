-- Binary file editing utilities
-- Automatically convert binary files to xxd format for editing

local M = {}

-- Get decimal value of hex under cursor
function M.get_hex_under_cursor()
    local line = vim.api.nvim_get_current_line()
    local col = vim.api.nvim_win_get_cursor(0)[2] + 1 -- Convert to 1-based indexing
    
    -- Extract 2 characters starting from current cursor position
    local hex = line:sub(col, col + 1)
    
    -- Check if it's a valid hex pair (2 hex digits)
    if hex:match("^%x%x$") then
        local decimal = tonumber(hex, 16)
        return string.format("0x%s = %d", hex, decimal)
    else
        return ""
    end
end

-- Setup binary file handling
function M.setup()
    local augroup = vim.api.nvim_create_augroup("binary", { clear = true })
    
    -- Pre-read: Set binary mode for binary files
    vim.api.nvim_create_autocmd("BufReadPre", {
        group = augroup,
        pattern = { "*.bin", "*.sav" },
        callback = function()
            vim.bo.binary = true
        end,
    })
    
    -- Post-read: Convert to xxd format if in binary mode
    vim.api.nvim_create_autocmd("BufReadPost", {
        group = augroup,
        pattern = { "*.bin", "*.sav" },
        callback = function()
            if vim.bo.binary then
                vim.cmd("%!xxd")
                vim.bo.filetype = "xxd"
            end
        end,
    })
    
    -- Pre-write: Convert from xxd format to binary if in binary mode
    vim.api.nvim_create_autocmd("BufWritePre", {
        group = augroup,
        pattern = { "*.bin", "*.sav" },
        callback = function()
            if vim.bo.binary then
                vim.cmd("%!xxd -r")
            end
        end,
    })
    
    -- Post-write: Convert back to xxd format and mark as unmodified
    vim.api.nvim_create_autocmd("BufWritePost", {
        group = augroup,
        pattern = { "*.bin", "*.sav" },
        callback = function()
            if vim.bo.binary then
                vim.cmd("%!xxd")
                vim.bo.modified = false
            end
        end,
    })
end

-- Initialize the module
M.setup()

return M