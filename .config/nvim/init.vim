" Plugin Custom Configurations:

    " Vim Fugitive: Git operations in vim
        nnoremap <leader>gs :Gstatus<CR>
        nnoremap <leader>gg :Ggrep! -iP <cword>
        noremap <leader>gb :Git blame<cr>
        noremap  <leader>gB <Plug>(gh-line-blame)
        cabbrev Glgrep Glgrep -i
        cabbrev Ggrep Ggrep -i
        cabbrev Gdiffsplit Gdiffsplit @{u}...
        command! Gdifftool Git difftool --name-only @{u}...

    " IndentLine: Disable Yggdroot/indentLine overrides
        let g:indentLine_concealcursor='c'

        " Certain fzf.vim commands do not work with fish shell
        set shell=sh

        let g:fzf_preview_window = ['up:60%:+{2}/4', 'ctrl-/']

        " FZF Buffer Delete
        function! s:list_buffers() abort
            redir => list
            silent ls
            redir END
            return split(list, "\n")
        endfunction

        function! s:delete_buffers(lines) abort
            " Use bdelete so buffers stay in locationlist
            execute 'bdelete' join(map(a:lines, {_, line -> split(line)[0]}))
        endfunction

        command! BDelete call fzf#run(fzf#wrap({ 'source': s:list_buffers(), 'sink*': { lines -> s:delete_buffers(lines) }, 'options': '--multi --reverse --bind ctrl-a:select-all+accept' }))

    " Ale:
        let g:ale_echo_msg_format = '[%linter%] %code: %%s'
        let g:ale_lint_on_insert_leave = 1
        let g:ale_lint_on_text_changed = 'normal'
        let g:ale_fix_on_save = 1
        let g:ale_fixers = {
                    \ 'javascript': [ 'eslint', 'prettier' ],
                    \ 'javascriptreact': [ 'eslint', 'prettier' ],
                    \ 'typescriptreact': [ 'eslint', 'prettier' ],
                    \ 'markdown': ['prettier' ],
                    \ 'python': ['black', 'isort', 'ruff', 'ruff_format'],
                    \ 'terraform': ['terraform'],
                    \ 'lua': ['stylua'],
                    \ '*': ['remove_trailing_lines', 'trim_whitespace']
                    \ }
        let g:ale_linters_ignore = {'python': ['bar'], 'javascript': [ 'tsserver'], '*': ['remove_trailing_lines', 'trim_whitespace']}
    " Vim Peeakboo:
        let g:peekaboo_window = "botright 30new"
        let g:peekaboo_delay = 300
    " SplitJoin:
        let g:splitjoin_python_brackets_on_separate_lines = 1
        let g:splitjoin_trailing_comma = 1
    " " CleverF:
    "     let g:clever_f_chars_match_any_signs = ';'
    " Sideways:
        nnoremap <leader><c-h> :SidewaysLeft<cr>
        nnoremap <leader><c-l> :SidewaysRight<cr>
    " Undotree:
        let g:undotree_SetFocusWhenToggle = 1
        let g:undotree_DiffCommand = 'diff -u'
        let g:undotree_ShortIndicators = 1
        let g:undotree_WindowLayout=2
    " Vim Asterisk:
        let g:asterisk#keeppos = 1
        map *  <Plug>(is-nohl)<Plug>(asterisk-z*)
        map #  <Plug>(is-nohl)<Plug>(asterisk-z#)
        map g* <Plug>(is-nohl)<Plug>(asterisk-gz*)
        map g# <Plug>(is-nohl)<Plug>(asterisk-gz#)
    " Vim Illuminate:
        let g:Illuminate_delay = 100
        hi link illuminatedWord Search
        let g:Illuminate_ftHighlightGroups = {
                    \ 'qf': [''],
                    \ 'javascript.jsx:blacklist': ['jsImport', 'jsExport', 'jsExportDefault', 'jsStorageClass', 'jsGlobalNodeObjects',
                    \       'jsClassKeyword', 'jsOperatorKeyword', 'jsExtendsKeyword', 'jsFrom', 'jsConditional', 'jsReturn'],
                    \ 'python': ['', 'pythonString', 'pythonFunction', 'pythonDottedName', 'pythonNone', 'pythonComment'],
                    \ }
    " Vim QF:
        let g:qf_mapping_ack_style = 1
        let g:qf_shorten_path = 0

    " CopilotChat
        " Github copilot suggestions
        inoremap <silent><script><expr> <m-l> copilot#Accept("\<CR>")
        map <leader>cc :CopilotChat<cr>
        map <leader>ce :CopilotChatExplain<cr>
        map <leader>cf :CopilotChatFix<cr>

" Insert Map:
    inoremap jk <esc>
    " Auto-correct while typing
    inoremap <c-l> <c-g>u<esc>[s1z=`]a<c-g>u

    iabbrev todo: TODO(TICKET):

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
    cmap w!! w !sudo tee >/dev/null %

" Terminal Mode Map:
    tnoremap <C-Space> <C-\><C-n>

lua <<EOF
EOF
