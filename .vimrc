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
    set shortmess+=IA       "no intro message, no swap-file message

" Vim Plug: Bootstrap vim-plug for fresh vim install
    if !filereadable(expand('~/.vim/autoload/plug.vim'))
      silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
      autocmd VimEnter * PlugInstall
    endif

    call plug#begin('~/.vim/bundle')
        " Git plugins
        Plug 'airblade/vim-gitgutter'
        Plug 'gregsexton/gitv', {'on': 'Gitv'}
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
        Plug 'mattn/vim-xxdcursor'

        " Usability
        Plug 'scrooloose/nerdtree', {'on': ['NERDTree', 'NERDTreeFind']}
        Plug 'Xuyuanp/nerdtree-git-plugin', {'on': ['NERDTree', 'NERDTreeFind']}
        Plug 'mbbill/undotree', {'on': 'UndotreeToggle'}
        Plug 'junegunn/fzf', { 'dir': '~/.local/share/fzf', 'do': './install --all' }
        Plug 'junegunn/fzf.vim'
        Plug 'junegunn/vim-peekaboo'
        Plug 'bronson/vim-visual-star-search'

        Plug 'vim-airline/vim-airline'
        Plug 'tmux-plugins/vim-tmux-focus-events'

        function! BuildYCM(info)
            " info is a dictionary with 3 fields
            " - name:   name of the plugin
            " - status: 'installed', 'updated', or 'unchanged'
            " - force:  set on PlugInstall! or PlugUpdate!
            if a:info.status == 'installed' || a:info.force

                if !executable('cmake')
                    echoerr 'Need cmake to install YCM!'
                endif

                !./install.py
            endif
        endfunction
        Plug 'Valloric/YouCompleteMe', { 'do': function('BuildYCM') }
    call plug#end()

" Plugin Custom Configurations:
    " YouCompleteMe: Enable a more fluid IDE experience.
        let g:ycm_add_preview_to_completeopt=1
        let g:ycm_autoclose_preview_window_after_completion=1
        " Use `env python` YCM/jedi server, instead of python vim uses
        let g:ycm_python_binary_path = 'python'
        map gd :YcmCompleter GoTo<cr>
        map gD :YcmCompleter GetDoc<cr>
        map gr :YcmCompleter GoToReferences<cr>
    " GitGutter: Git status while editing files
        set updatetime=250
        set signcolumn=yes
    " Vim Fugitive: Git operations in vim
        nnoremap <leader>gs :Gstatus<CR>
        nnoremap <leader>gg :Ggrep -iP <cword>
    " Gitv: Expand Vim-Fugititve git log operations
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
    " Fzf:
        nnoremap <leader>fb :Buffers<CR>
        nnoremap <leader>fg :GFiles<CR>
        nnoremap <leader>fG :GFiles?<CR>
        nnoremap <leader>fl :Lines<CR>
        nnoremap <leader>/ :BLines<CR>
    " Ale:
        let g:ale_echo_msg_format = '[%linter%] %code: %%s'
        let g:ale_lint_on_insert_leave = 1
        let g:ale_lint_on_text_changed = 'normal'
    " Vim_Peeakboo:
        let g:peekaboo_window = "botright 30new"
        let g:peekaboo_delay = 300
    " SplitJoin:
        let g:splitjoin_python_brackets_on_separate_lines = 1
        let g:splitjoin_trailing_comma = 1

" Status_Line:
    set noshowmode

" Insert_map:
    inoremap jk <esc>

    iabbrev todo: TODO(user#ticket\|201x-xx-yy):

" Normal_Map:
    nnoremap <leader><c-j> :lnext<CR>
    nnoremap <leader><c-k> :lprevious<CR>
    nnoremap <leader>j :cnext<CR>
    nnoremap <leader>k :cprevious<CR>
    nnoremap <C-e> 5<C-e>
    nnoremap <C-y> 5<C-y>
    nnoremap Y y$
    noremap go o<esc>
    noremap gO O<esc>
    noremap <m-o> <C-I>
    nnoremap <leader>bd :b#<cr>:bd #<cr>

    nnoremap <leader><space> :
    nmap <space> <leader>

    nnoremap <leader><c-h> :SidewaysLeft<cr>
    nnoremap <leader><c-l> :SidewaysRight<cr>

    " Window Movement:
    nnoremap <c-j> <c-w><c-j>
    nnoremap <c-k> <c-w><c-k>
    nnoremap <c-l> <c-w><c-l>
    nnoremap <c-h> <c-w><c-h>

" Commandline_map:
    cmap <c-p> <up>
    cmap <c-n> <down>
    cmap w!! w !sudo tee >/dev/null %

    cabbrev Glgrep Glgrep -i
    cabbrev Ggrep Ggrep -i

" Format_Option:
    set formatoptions +=b   " Break at blank. No autowrapping if line is >textwidth before insert or no blank
    set formatoptions +=j   " Remove comment leader when joining lines
    set formatoptions +=c   " Insert comment leader when wrapping lines
    set formatoptions +=r   " Insert comment leader in insert mode when <CR>
    set formatoptions +=o   " Insert comment leader for o/O in normal mode
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
    if has('nvim')
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
        if exists("$VIRTUAL_ENV")
            " Skip the activated virtualenv, which probably doesn't have neovim package
            let g:python3_host_prog = system("type -ap python3 | head -n2 | tail -n1")[:-2]
            let g:python_host_prog = system("type -ap python2 | head -n2 | tail -n1")[:-2]
        else
            let g:python3_host_prog = system("command -v python3")[:-2]
            let g:python_host_prog = system("command -v python2")[:-2]
        endif
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

    set shell=/bin/bash

    syntax enable
    colorscheme ir_black
    filetype plugin on
    highlight Search cterm=reverse,underline

" Autocmd:
    autocmd FileType sql set expandtab
    autocmd FileType yaml set ts=2 sw=2
    autocmd BufReadPost quickfix nnoremap <buffer> <cr> <cr>
    autocmd Filetype gitcommit setlocal spell textwidth=72 nocursorline
    autocmd QuickFixCmdPost [^l]* nested cwindow
    autocmd QuickFixCmdPost l* nested lwindow
    autocmd FileType python :iabbrev <buffer> pudb import pudb; pu.db # noqa
    autocmd FileType markdown setlocal spell
    autocmd BufNewFile,BufRead *.avsc set filetype=json

    " Diffs use diff foldmethod
    if !&diff
        " These files, when properly formatted, can use the indent method for folding
        autocmd BufNewFile,BufRead,FileType *.cs set foldmethod=indent
        autocmd BufNewFile,BufRead,FileType *.xml set foldmethod=indent
        " Python is a perfect candidate for indent foldmethod because it is whitespace significant
        autocmd BufNewFile,BufRead,FileType *.py set foldmethod=indent
    endif

" Diff Colours: Override the diff colours in ir_black
    hi DiffAdd      ctermfg=195 ctermbg=34
    hi DiffDelete   ctermfg=000 ctermbg=88
    hi diffchange   ctermfg=249 ctermbg=27
    hi difftext     ctermfg=255 ctermbg=9
    hi PmenuSel     ctermfg=51  ctermbg=236
    hi CursorColumn             ctermbg=233
    hi CursorLine               ctermbg=236
    hi NonText      ctermfg=247 ctermbg=237 cterm=bold

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
