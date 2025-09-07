" Plugin Custom Configurations:
    " Vim QF:
        let g:qf_mapping_ack_style = 1
        let g:qf_shorten_path = 0

" Insert Map:
    inoremap jk <esc>
    " Auto-correct while typing
    inoremap <c-l> <c-g>u<esc>[s1z=`]a<c-g>u

" Normal Map:
    nnoremap <C-e> 5<C-e>
    nnoremap <C-y> 5<C-y>
    nnoremap Y y$
    noremap <m-o> <C-I>
    nnoremap <leader>bd :b#<cr>:bd #<cr>


    " Quickfix/Location List
    nmap <leader><F5> :cwindow<CR>
    nmap <leader><F6> :lwindow<CR>


    " Window Movement:
    nnoremap <c-j> <c-w><c-j>
    nnoremap <c-k> <c-w><c-k>
    nnoremap <c-l> <c-w><c-l>
    nnoremap <c-h> <c-w><c-h>

" Commandline Map:
    cnoremap <c-p> <up>
    cnoremap <c-n> <down>
    " Unsure why vim decided to deviate from readline here, it's not like this was already mapped
    cnoremap <c-a> <c-b>

" Terminal Mode Map:
    tnoremap <C-Space> <C-\><C-n>

lua <<EOF
EOF
