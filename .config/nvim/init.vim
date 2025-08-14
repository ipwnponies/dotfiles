" Plugin Custom Configurations:

    " GitGutter: Git status while editing files
        set updatetime=250
        set signcolumn=yes
    " Vim Fugitive: Git operations in vim
        nnoremap <leader>gs :Gstatus<CR>
        nnoremap <leader>gg :Ggrep! -iP <cword>
        noremap <leader>gb :Git blame<cr>
        noremap  <leader>gB <Plug>(gh-line-blame)
        cabbrev Glgrep Glgrep -i
        cabbrev Ggrep Ggrep -i
        cabbrev Gdiffsplit Gdiffsplit @{u}...
        command! Gdifftool Git difftool --name-only @{u}...

    " Gitv: Expand Vim-Fugitive git log operations
        let g:Gitv_DoNotMapCtrlKey = 1
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

" Format Option:
    set formatoptions +=b   " Break at blank. No autowrapping if line is >textwidth before insert or no blank
    set formatoptions +=j   " Remove comment leader when joining lines
    set formatoptions +=c   " Insert comment leader when wrapping lines
    set formatoptions +=r   " Insert comment leader in insert mode when <CR>
    set formatoptions +=q   " Allow gq for comments
    if has("patch-7.3.541")
        set formatoptions+=j
    endif

" Settings:
    " Search
    set hlsearch
    set incsearch
    set ignorecase
    set smartcase
    set gdefault
    if exists('&inccommand')
        set inccommand=split
    endif

    " Spaces, tabs, indents
    set expandtab
    set tabstop=4
    set softtabstop=0
    set shiftwidth=0
    set autoindent

    " Diff and folds
    set foldmethod=syntax
    set nofoldenable
    set diffopt+=vertical
    set diffopt+=context:2

    " Completion
    set wildmode=full
    set wildmenu
    set wildignorecase
    set noinfercase
    set completeopt=menuone,preview

    " Visuals
    set visualbell
    set cursorline
    set number
    set scrolloff=3
    set showmatch
    set showcmd
    set showbreak=>>
    set linebreak   " Break at word boundary
    set breakindent " Indent hanging continued lines
    " Show showbreak character at far left, shift by 4, and keep hanging indents
    " at least minimum 60 width (for overly indented long lines)
    set breakindentopt=sbr,shift:4,min:60

    " Layout
    set textwidth=120
    set splitbelow
    set splitright
    set switchbuf=useopen

    " Temp file directories
    let &undodir = expand('~/.cache/vim/undo//')
    let &directory = expand('~/.cache/vim/swp//')
    if !isdirectory(&undodir) || !isdirectory(&directory)
        execute 'silent !mkdir -p ' . &undodir . ' ' . &directory
    endif

    " Persistent Undo
    set undofile

    " Local overrides
    set exrc

    " Misc
    set hidden
    set modeline
    set mouse=a

    syntax enable
    filetype plugin on

" Colors:
    set termguicolors
    highlight Pmenu ctermbg=26
    highlight PmenuSel ctermfg=214
    highlight Visual ctermbg=237 guibg=#535D7E
    highlight Search cterm=bold gui=bold gui=reverse guifg=None guibg=#53575c

" Autocmd:
    autocmd! FileType sql set expandtab
    autocmd! BufReadPost quickfix nnoremap <buffer> <cr> <cr>
    autocmd! Filetype gitcommit setlocal spell textwidth=72 nocursorline
    autocmd! QuickFixCmdPost [^l]* nested cwindow
    autocmd! QuickFixCmdPost l* nested lwindow
    autocmd! BufNewFile,BufRead *.avsc set filetype=json
    autocmd! TermOpen * setlocal nonumber
    autocmd! BufRead,BufNewfile *.tmpl set filetype=htmlcheetah

    " Diffs use diff foldmethod
    if !&diff
        " These files, when properly formatted, can use the indent method for folding
        autocmd BufNewFile,BufRead,FileType *.cs set foldmethod=indent
        autocmd BufNewFile,BufRead,FileType *.xml set foldmethod=indent
        " Python is a perfect candidate for indent foldmethod because it is whitespace significant
        autocmd BufNewFile,BufRead,FileType *.py set foldmethod=indent
    endif

lua <<EOF
EOF
