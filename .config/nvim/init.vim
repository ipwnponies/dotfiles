" Plugin Custom Configurations:
    " Vim QF:
        let g:qf_mapping_ack_style = 1
        let g:qf_shorten_path = 0

" Normal Map:
    noremap <m-o> <C-I>

" Commandline Map:
    cnoremap <c-p> <up>
    cnoremap <c-n> <down>
    " Unsure why vim decided to deviate from readline here, it's not like this was already mapped
    cnoremap <c-a> <c-b>

" Terminal Mode Map:
    tnoremap <C-Space> <C-\><C-n>

lua <<EOF
EOF
