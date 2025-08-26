vim.opt.termguicolors = true

vim.api.nvim_set_hl(0, "Pmenu", { ctermbg = 26 })
vim.api.nvim_set_hl(0, "PmenuSel", { ctermfg = 214 })
vim.api.nvim_set_hl(0, "Visual", { ctermbg = 237, bg = "#535D7E" })
vim.api.nvim_set_hl(0, "Search", { cterm = { bold = true }, bold = true, reverse = true, bg = "#53575c" })

-- LSP reference highlights
vim.api.nvim_set_hl(0, "LspReferenceRead", { ctermbg = 237, bg = "Green" })
vim.api.nvim_set_hl(0, "LspReferenceWrite", { ctermbg = 237, bg = "Brown" })
vim.api.nvim_set_hl(0, "LspReferenceText", { bg = "#53575c" })
