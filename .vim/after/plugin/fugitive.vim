" Vim Fugitive: {
    augroup fugitive_status
        " The auto group is cleared by vim fugitive
        autocmd VimEnter,WinEnter * if &previewwindow | let &winheight=&lines*1/4 | endif
    augroup END
" }
