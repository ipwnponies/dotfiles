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
        Plug 'jreybert/vimagit', {'on': ['Magit', 'MagitOnly']}

        " Lang-specific
        Plug 'hynek/vim-python-pep8-indent'
        Plug 'rodjek/vim-puppet', { 'for': 'puppet' }
        Plug 'w0rp/ale'
        Plug 'plasticboy/vim-markdown', {'for': 'markdown'}
        Plug 'dag/vim-fish', {'for': 'fish'}

        " Editing
        Plug 'tpope/vim-commentary'
        Plug 'tpope/vim-surround'
        Plug 'tpope/vim-sensible'
        Plug 'tpope/vim-endwise'
        Plug 'tpope/vim-dispatch'
        Plug 'Yggdroot/indentLine'
        Plug 'junegunn/vim-easy-align'

        " Usability
        Plug 'scrooloose/nerdtree', {'on': ['NERDTree', 'NERDTreeFind']}
        Plug 'Xuyuanp/nerdtree-git-plugin', {'on': ['NERDTree', 'NERDTreeFind']}
        Plug 'mbbill/undotree', {'on': 'UndotreeToggle'}
        Plug 'junegunn/fzf', { 'dir': '~/.local/share/fzf', 'do': './install --all' }
        Plug 'junegunn/fzf.vim'
        Plug 'junegunn/vim-peekaboo'

        Plug 'vim-airline/vim-airline'
        Plug 'tmux-plugins/vim-tmux-focus-events'

        function! BuildYCM(info)
            " info is a dictionary with 3 fields
            " - name:   name of the plugin
            " - status: 'installed', 'updated', or 'unchanged'
            " - force:  set on PlugInstall! or PlugUpdate!
            if a:info.status == 'installed' || a:info.force
                let gcc_version = system('g++ -dumpversion')[:-2]
                if gcc_version == '4.6'
                    !/bin/sh -c 'CXX=g++-4.8 ./install.py'
                else
                    !./install.py
                endif
            endif
        endfunction
        Plug 'Valloric/YouCompleteMe', { 'do': function('BuildYCM'), 'commit': '61b5aa7' }
    call plug#end()

" Plugin Custom Configurations:
    " YouCompleteMe: Enable a more fluid IDE experience.
        let g:ycm_add_preview_to_completeopt=1
        let g:ycm_autoclose_preview_window_after_completion=1
        map gd :YcmCompleter GoTo<cr>
        map gD :YcmCompleter GetDoc<cr>
        map gr :YcmCompleter GoToReferences<cr>
    " GitGutter: Git status while editing files
        set updatetime=250
    " Vim Fugitive: Git operations in vim
        nnoremap <leader>gs :Gstatus<CR>
        nnoremap <leader>gg :Ggrep -i <cword>
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
    " Ale:
        let g:ale_echo_msg_format = '[%linter%] %code: %%s'
        let g:ale_lint_on_insert_leave = 1
        let g:ale_lint_on_text_changed = 'normal'
    " Vim_Peeakboo:
        let g:peekaboo_window = "botright 30new"

" Status_Line:
    set noshowmode

" Insert_map:
    inoremap jj <esc>

    iabbrev teh the
    iabbrev waht what

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

    nnoremap <cr> :
    nmap <space> <leader>

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

    " Spaces, tabs, indents
    set expandtab
    set tabstop=4
    set softtabstop=4
    set shiftwidth=4
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

    " Visuals
    set visualbell
    set cursorline
    set number
    set scrolloff=3
    set showmatch
    set showcmd
    set showbreak=>>
    if has('nvim')
        set inccommand=split

        " Figure out the python virtualenv for neovim
        " Skip the activated virtualenv, which probably doesn't have neovim package
        if exists("$VIRTUAL_ENV")
            let g:python3_host_prog = system("type -ap python3 | head -n2 | tail -n1")[:-2]
            let g:python_host_prog = system("tpye -ap python2 | head -n2 | tail -n1")[:-2]
        else
            let g:python3_host_prog = system("command -v python3")[:-2]
            let g:python_host_prog = system("command -v python2")[:-2]
        endif
    endif
    set gdefault

    " Layout
    set textwidth=100
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

    set shell=/bin/bash

" Misc:
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
