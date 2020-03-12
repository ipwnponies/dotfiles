" neovim and vim compatibility
    " We need to set this so that plugins won't break. Apparently vim still lives in the savage past but many plugins
    " have moved on with life. This is duped with vim-sensible but we need this for bootstrapping.
    set nocompatible

" Multiple Files:
    " be smarter about multiple buffers / vim instances
    "quick buffer switching with TAB, even with edited files
    set hidden
    nmap <TAB> :bn<CR>
    nmap <S-TAB> :bp<CR>
    set autoread            "auto-reload files, if there's no conflict
    set shortmess+=IA       "no intro message, no swap-file message, no completions
    let mapleader = "\<space>" " Must be set early, so that plugin mappings are deterministic

execute 'source ' . fnamemodify($MYVIMRC, ':p:h') . '/init_local.vim'

" Vim Plug: Bootstrap vim-plug for fresh vim install
    if !filereadable(expand('~/.vim/autoload/plug.vim'))
      silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
      autocmd VimEnter * PlugInstall
    endif

    call plug#begin('~/.vim/bundle')
        " Git plugins
        Plug 'airblade/vim-gitgutter'
        " Use pre-release build, which has fugitive compatbility fixes
        Plug 'gregsexton/gitv', {'on': 'Gitv', 'commit': 'e9486c2da297634dde7bc591b87fb8c0779b7789'}
        Plug 'tpope/vim-fugitive'

        " Lang-specific
        Plug 'w0rp/ale'
        Plug 'sheerun/vim-polyglot'

        " Editing
        Plug 'tpope/vim-commentary'
        Plug 'tpope/vim-surround'
        Plug 'tpope/vim-sensible'
        Plug 'tpope/vim-endwise'
        Plug 'Yggdroot/indentLine'
        Plug 'junegunn/vim-easy-align'
        Plug 'AndrewRadev/sideways.vim'
        Plug 'AndrewRadev/splitjoin.vim'
        Plug 'michaeljsmith/vim-indent-object'
        Plug 'jeetsukumaran/vim-indentwise'
        Plug 'voithos/vim-python-matchit'
        Plug 'mattn/vim-xxdcursor'

        " Usability
        Plug 'scrooloose/nerdtree', {'on': ['NERDTree', 'NERDTreeFind']}
        Plug 'Xuyuanp/nerdtree-git-plugin', {'on': ['NERDTree', 'NERDTreeFind']}
        Plug 'mbbill/undotree', {'on': 'UndotreeToggle'}
        Plug 'junegunn/fzf', { 'dir': '~/.local/share/fzf', 'do': './install --all' }
        Plug 'junegunn/fzf.vim'
        Plug 'junegunn/vim-peekaboo'
        Plug 'haya14busa/vim-asterisk'
        Plug 'romainl/vim-qf'
        Plug 'easymotion/vim-easymotion'
        Plug 'tpope/vim-unimpaired'

        " Pretty
        Plug 'vim-airline/vim-airline'
        Plug 'sickill/vim-monokai'
        Plug 'haya14busa/incsearch.vim'
        Plug 'RRethy/vim-illuminate'

        " IDE
        Plug 'neoclide/coc.nvim', {'branch': 'release'}
    call plug#end()

" Plugin Custom Configurations:
    " Coc:
        " Settings:
            let g:airline#extensions#coc#enabled = 1
            let g:coc_extension_root = $XDG_DATA_HOME . '/coc/extensions'
        " Insert Mapping:
        " Used to interact with completion popup menu
            inoremap <silent><expr> <Tab> pumvisible() ? '<C-n>' : <SID>check_back_space() ? '<Tab>' : coc#refresh()
            inoremap <expr> <S-Tab> pumvisible() ? '<C-p>' : '<S-Tab>'
            inoremap <silent><expr> <c-space> coc#refresh()

            function! s:check_back_space() abort
              let col = col('.') - 1
              return !col || getline('.')[col - 1]  =~ '\s'
            endfunction
        " Normal Mappings:
        " Used to interact with LSP servers
            nmap gd <Plug>(coc-definition)
            nmap gD :call CocActionFzf()<cr>

            function! CocActionFzf()
                let l:availableActions = ['jumpDefinition', 'rename', 'jumpReferences', 'quickfixes', 'doHover', 'showSignatureHelp', 'jumpTypeDefinition', 'jumpImplementation', 'jumpDeclaration', 'format', 'formatSelected', 'workspaceSymbols', 'getCurrentFunctionSymbol',]
                call fzf#run(fzf#wrap({'source': l:availableActions, 'sink': function('s:cocRunAction')}))
            endfunction

            function! s:cocRunAction(action)
               call CocAction(a:action)
            endfunction
    " GitGutter: Git status while editing files
        set updatetime=250
        if exists('&signcolumn') | set signcolumn=yes | endif
    " Vim Fugitive: Git operations in vim
        nnoremap <leader>gs :Gstatus<CR>
        nnoremap <leader>gg :Ggrep! -iP <cword>
    " Gitv: Expand Vim-Fugitive git log operations
        let g:Gitv_DoNotMapCtrlKey = 1
    " IndentLine: Disable Yggdroot/indentLine overrides
        let g:indentLine_concealcursor='c'
    " VimAirline:
        let g:airline#extensions#tabline#enabled = 1
    " NerdTree:
        nnoremap <leader>n :NERDTree<CR>
        nnoremap <leader>nf :NERDTreeFind<CR>
        let NERDTreeMapOpenVSplit='v'
        let NERDTreeMapOpenSplit='s'
        let NERDTreeQuitOnOpen=1
    " Fzf:
        nnoremap <leader>fb :Buffers<CR>
        nnoremap <leader>ff :FZF<CR>
        nnoremap <leader>fg :GFiles<CR>
        nnoremap <leader>fG :GFiles?<CR>
        nnoremap <leader>fl :Lines<CR>
        nnoremap <leader>/ :BLines<CR>
        nnoremap <leader>fc :Commands<CR>
        nnoremap <leader>fh :Helptags<CR>
        nnoremap <leader>fC :BCommits<CR>
    " Ale:
        let g:ale_echo_msg_format = '[%linter%] %code: %%s'
        let g:ale_lint_on_insert_leave = 1
        let g:ale_lint_on_text_changed = 'normal'
        let g:ale_fixers = ['remove_trailing_lines', 'trim_whitespace']
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
    " EasyMotion:
        let g:EasyMotion_use_upper = 1
        let g:EasyMotion_use_smartsign_us = 1
        let g:EasyMotion_smartcase = 1
        let g:EasyMotion_do_shade = 0
        let g:EasyMotion_enter_jump_first = 1
        let g:EasyMotion_keys = 'ASDGHKLQWERTYUIOPZXCVBNMFJ;'
        map ; <Plug>(easymotion-prefix)
        map s <Plug>(easymotion-sn)
        map <Plug>(easymotion-prefix)/ <Plug>(easymotion-sn)
        map <Plug>(easymotion-prefix)w <Plug>(easymotion-bd-w)
        map <Plug>(easymotion-prefix)W <Plug>(easymotion-bd-W)
    " Vim Asterisk:
        let g:asterisk#keeppos = 1
        map *  <Plug>(incsearch-nohl)<Plug>(asterisk-z*)
        map #  <Plug>(incsearch-nohl)<Plug>(asterisk-z#)
        map g* <Plug>(incsearch-nohl)<Plug>(asterisk-gz*)
        map g# <Plug>(incsearch-nohl)<Plug>(asterisk-gz#)
    " Incsearch:
        let g:incsearch#auto_nohlsearch = 1
        map n  <Plug>(incsearch-nohl-n)
        map N  <Plug>(incsearch-nohl-N)
        map /  <Plug>(incsearch-forward)
        map ?  <Plug>(incsearch-backward)
        map g/ <Plug>(incsearch-stay)
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
    nmap <leader>c <Plug>(qf_qf_switch)
    nmap <leader><F5> <Plug>(qf_qf_toggle_stay)
    nmap <leader><F6> <Plug>(qf_loc_toggle_stay)


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

    cabbrev Glgrep Glgrep -i
    cabbrev Ggrep Ggrep -i

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

    " Figure out the python virtualenv for neovim.
    " This only applies to interactive mode, put stuff in here that breaks due to interaction with tty.
    if has('nvim') && has('ttyin') && has('ttyout')
        " system will start a subshell, where PATH ordering will be reestablished.
        " This will correctly ignore any activated python virtualenvs.
        let g:python3_host_prog = system("command -v python3")[:-2]
        let g:python_host_prog = system("command -v python2")[:-2]
    endif

    " Visuals
    set visualbell
    set cursorline
    set number
    set scrolloff=3
    set showmatch
    set showcmd
    set showbreak=>>

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

    " Misc
    set pastetoggle=<f2>
    set hidden
    set backspace=2
    set modeline
    set mouse=a

    syntax enable
    filetype plugin on

" Colors:
    colorscheme monokai
    highlight Pmenu ctermbg=26
    highlight PmenuSel ctermfg=214
    highlight Search cterm=bold ctermfg=40 ctermbg=NONE gui=bold guifg=#7fbf00

" Autocmd:
    autocmd FileType sql set expandtab
    autocmd FileType yaml set ts=2 sw=2
    autocmd BufReadPost quickfix nnoremap <buffer> <cr> <cr>
    autocmd Filetype gitcommit setlocal spell textwidth=72 nocursorline
    autocmd QuickFixCmdPost [^l]* nested cwindow
    autocmd QuickFixCmdPost l* nested lwindow
    autocmd FileType python :iabbrev <buffer> pudb import pudb; pu.db # noqa
    autocmd FileType javascript.jsx :iabbrev <buffer> debugger debugger; // eslint-disable-line
    autocmd FileType markdown setlocal spell
    autocmd BufNewFile,BufRead *.avsc set filetype=json
    autocmd TermOpen * setlocal nonumber
    autocmd BufRead,BufNewfile *.tmpl set filetype=htmlcheetah

    " Diffs use diff foldmethod
    if !&diff
        " These files, when properly formatted, can use the indent method for folding
        autocmd BufNewFile,BufRead,FileType *.cs set foldmethod=indent
        autocmd BufNewFile,BufRead,FileType *.xml set foldmethod=indent
        " Python is a perfect candidate for indent foldmethod because it is whitespace significant
        autocmd BufNewFile,BufRead,FileType *.py set foldmethod=indent
    endif

" BinaryEditing:
    " Automatically convert to xxd format upon read and write
    augroup binary
        autocmd!
        autocmd BufReadPre  *.bin,*.sav let &bin=1
        autocmd BufReadPost *.bin,*.sav if &bin | %!xxd
        autocmd BufReadPost *.bin,*.sav set ft=xxd | endif
        autocmd BufWritePre *.bin,*.sav if &bin | %!xxd -r
        autocmd BufWritePre *.bin,*.sav endif
        autocmd BufWritePost *.bin,*.sav if &bin | %!xxd
        autocmd BufWritePost *.bin,*.sav set nomod | endif
    augroup END

    " Get decimal value of hex under cursor
    function! GetHexUnderCursor()
        let hex = getline(".")[col('.')-1:col('.')]
        return hex =~ '\x\{2\}' ? '0x' + str2nr(hex, 16) : ''
    endfunction

    " Register with vim-airline
    call airline#parts#define_function('convertHex', 'GetHexUnderCursor')
    let g:airline_section_y = airline#section#create_right(['ffenc','convertHex'])
