" multiple files {
    " be smarter about multiple buffers / vim instances
    "quick buffer switching with TAB, even with edited files
    set hidden
    nmap <TAB> :bn<CR>
    nmap <S-TAB> :bp<CR>
    set autoread            "auto-reload files, if there's no conflict
    set shortmess+=IA       "no intro message, no swap-file message

    "replacement for CTRL-I, also known as <tab>
    noremap <C-P> <C-I>
" }

" Vim-Plug: {
    " Bootstrap vim-plug for fresh vim install
    if empty(glob('~/.vim/autoload/plug.vim'))
      silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
      autocmd VimEnter * PlugInstall
    endif

    call plug#begin('~/.vim/bundle')
        " Git plugins
        Plug 'airblade/vim-gitgutter'
        Plug 'gregsexton/gitv'
        Plug 'tpope/vim-fugitive'

        " Lang-specific
        Plug 'hynek/vim-python-pep8-indent'
        Plug 'rodjek/vim-puppet'
        Plug 'scrooloose/syntastic'
        Plug 'plasticboy/vim-markdown'

        " Functionality
        Plug 'roxma/vim-paste-easy'
        Plug 'tpope/vim-commentary'
        Plug 'tpope/vim-surround'
        Plug 'tpope/vim-sensible'
        Plug 'tpope/vim-endwise'
        Plug 'tpope/vim-dispatch'
        Plug 'mbbill/undotree'
        Plug 'Yggdroot/indentLine'
        Plug 'scrooloose/nerdtree'
        Plug 'Xuyuanp/nerdtree-git-plugin'

        function! BuildYCM(info)
            " info is a dictionary with 3 fields
            " - name:   name of the plugin
            " - status: 'installed', 'updated', or 'unchanged'
            " - force:  set on PlugInstall! or PlugUpdate!
            if a:info.status == 'installed' || a:info.force
                let gcc_version = system('g++ -dumpversion')[:-2]
                if gcc_version == '4.6'
                    !CXX=g++-4.8 ./install.py
                else
                    !./install.py
                endif
            endif
        endfunction
        Plug 'Valloric/YouCompleteMe', { 'do': function('BuildYCM') }
    call plug#end()
" }

" YouCompleteMe: {
    " Enable a more fluid IDE experience.
    let g:ycm_add_preview_to_completeopt=1
    let g:ycm_autoclose_preview_window_after_completion=1
    map gd :YcmCompleter GoTo<cr>
    map gD :YcmCompleter GetDoc<cr>
    map gr :YcmCompleter GoToReferences<cr>
" }

" GitGutter: {
    " Git status while editing files
    set updatetime=250
" }

" VimFugitive: {
    nnoremap gs :Gstatus<CR>
" }

" Status_Line: {
    set statusline =                " clear!
    set statusline +=%<             " truncation point
    set statusline +=%2n:           " buffer number
    set statusline +=%f\            " relative path to file
    set statusline +=%#Error#       " BEGIN error highlighting
    set statusline +=%m             " modified flag [+]
    set statusline +=%r             " readonly flag [RO]
    set statusline +=%##            " END error highlighting
    set statusline +=%y             " filetype [ruby]
    set statusline +=%=             " split point for left and right justification
    set statusline +=col:%2v\      " current virtual column number (visual count)
    set statusline +=row:%3l      " current line number
    set statusline +=/%-L\         " number of lines in buffer
    set statusline +=%2p%%\         " percentage through buffer
" }

" Insert_map: {
    inoremap jj <esc>

    iabbrev teh the
    iabbrev waht what
" }

" Normal_Map: {
    nnoremap <c-j> :lnext<CR>
    nnoremap <c-k> :lprevious<CR>
    nnoremap <C-e> 5<C-e>
    nnoremap <C-y> 5<C-y>
    nnoremap Y y$
    noremap go o<esc>
    noremap gO O<esc>
    noremap <esc>o <c-i>

    " Open up all folds
    noremap <space> zO

    " Ctrl-Space to update folds to current cursor
    noremap <C-@> zxzczO
" }

" Visual_map: {
    vnoremap <space> zf
" }

" Commandline_map: {
    cmap <c-p> <up>
    cmap <c-n> <down>
    cmap w!! w !sudo tee >/dev/null %
" }

" Settings 
set number

" Format_Option: {
    set formatoptions +=b   " Break at blank. No autowrapping if line is >textwidth before insert or no blank
    set formatoptions +=j   " Remove comment leader when joining lines
    set formatoptions +=c   " Insert comment leader when wrapping lines
    set formatoptions +=r   " Insert comment leader in insert mode when <CR>
    set formatoptions +=o   " Insert comment leader for o/O in normal mode
    set formatoptions +=q   " Allow gq for comments
" }
if has("patch-7.3.541")
    set formatoptions+=j
endif

set autoindent
set textwidth=100
set scrolloff=3
set hlsearch
set expandtab
set tabstop=4
set softtabstop=4
set shiftwidth=4
set smartcase
set noinfercase
set backspace=2
set foldmethod=syntax
set ruler
set incsearch
set hidden
set wildmode=full
set wildmenu
set wildignorecase
set visualbell
set ignorecase
set cursorcolumn
set cursorline
set nofoldenable

set pastetoggle=<f2>

set diffopt+=vertical
set diffopt+=context:2

syntax enable
colorscheme ir_black
filetype plugin on
highlight Search cterm=reverse,underline

" Filetype Settings: {
autocmd BufNewFile,BufRead,FileType *.sql set expandtab
autocmd BufNewFile,BufRead,FileType *.sql set nonumber
autocmd BufNewFile,BufRead,FileType *.yaml set ts=2 sw=2

" Diffs use diff foldmethod
if !&diff
    " These files, when properly formatted, can use the indent method for folding
	autocmd BufNewFile,BufRead,FileType *.cs set foldmethod=indent
	autocmd BufNewFile,BufRead,FileType *.xml set foldmethod=indent
    " Python is a perfect candidate for indent foldmethod because it is whitespace significant
	autocmd BufNewFile,BufRead,FileType *.py set foldmethod=indent
endif
" }

" Diff Colours: {
    " Override the diff colours in ir_black
    hi DiffAdd      ctermfg=195 ctermbg=34
    hi DiffDelete   ctermfg=000 ctermbg=88
    hi diffchange   ctermfg=249 ctermbg=27
    hi difftext     ctermfg=255 ctermbg=9
    hi PmenuSel     ctermfg=51  ctermbg=236
    hi CursorColumn             ctermbg=233
    hi CursorLine               ctermbg=236
" }
