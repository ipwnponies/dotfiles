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

" Pathogen: {
    " keep plugins nicely bundled in separate folders.
    " http://www.vim.org/scripts/script.php?script_id=2332
    runtime autoload/pathogen.vim
    if exists('g:loaded_pathogen')
        call pathogen#infect()    "load the bundles, if possible
        Helptags                  "plus any bundled help
        runtime bundle_config.vim "give me a chance to configure the plugins
    endif
" }

" YouCompleteMe: {
    " Enable a more fluid IDE experience.
    let g:ycm_add_preview_to_completeopt=1
    let g:ycm_autoclose_preview_window_after_completion=1
    map gd :YcmCompleter GoTo<cr>
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
" }

" Normal_Map: {
    nnoremap <c-j> gj
    nnoremap <c-k> gk
    nnoremap <C-e> 5<C-e>
    nnoremap <C-y> 5<C-y>
    nnoremap Y y$
    noremap go o<esc>
    noremap gO O<esc>
    noremap <space> za
" }

" Visual_map: {
    vnoremap <space> zf
" }

" Commandline_map: {
    cmap <c-p> <up>
    cmap <c-n> <down>
" }

" Settings 
set number
set formatoptions+=orcb
if has("patch-7.3.541")
    set formatoptions+=j
endif

set textwidth=130
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

syntax enable
colorscheme ir_black
filetype plugin on
highlight Search cterm=reverse,underline

set autoindent
autocmd BufNewFile,BufRead,FileType *.sql set expandtab
autocmd BufNewFile,BufRead,FileType *.sql set nonumber

if !&diff
	autocmd BufNewFile,BufRead,FileType *.cs set foldmethod=indent
	autocmd BufNewFile,BufRead,FileType *.xml set foldmethod=indent
	autocmd BufNewFile,BufRead,FileType *.py set foldmethod=indent
endif

" Diff colours. Didn't want to put this in ir_black but we may fork ir_black to add this
hi DiffAdd      ctermfg=234 ctermbg=34 
hi DiffDelete   ctermfg=000 ctermbg=88
hi diffchange   ctermfg=249 ctermbg=27
hi difftext     ctermfg=255 ctermbg=9
hi PmenuSel     ctermfg=51  ctermbg=236
hi CursorColumn             ctermbg=233
hi CursorLine               ctermbg=236
