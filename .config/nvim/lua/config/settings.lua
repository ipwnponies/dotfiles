vim.g["airline#extensions#tabline#enabled"] = 1
vim.g.sonokai_style = "shusia"
vim.cmd([[colorscheme sonokai]])

-- LSP reference highlights
vim.api.nvim_set_hl(0, 'LspReferenceRead', { ctermbg = 237, bg = 'Green' })
vim.api.nvim_set_hl(0, 'LspReferenceWrite', { ctermbg = 237, bg = 'Brown' })
vim.api.nvim_set_hl(0, 'LspReferenceText', { bg = '#53575c' })
