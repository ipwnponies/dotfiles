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

" Vim Plug: Bootstrap vim-plug for fresh vim install
    if !filereadable(expand('~/.vim/autoload/plug.vim'))
      silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
      autocmd! VimEnter * PlugInstall
    endif

    call plug#begin('~/.vim/bundle')
        " Git plugins
        Plug 'airblade/vim-gitgutter'
        Plug 'junegunn/gv.vim'
        Plug 'tpope/vim-fugitive'
        Plug 'ruanyl/vim-gh-line'

        " Lang-specific
        Plug 'w0rp/ale'
        Plug 'sheerun/vim-polyglot'
        Plug 'voithos/vim-python-matchit'

        " Editing
        Plug 'tpope/vim-commentary'
        Plug 'machakann/vim-sandwich'
        Plug 'tpope/vim-sensible'
        Plug 'tpope/vim-endwise'
        Plug 'Yggdroot/indentLine'
        Plug 'junegunn/vim-easy-align'
        Plug 'AndrewRadev/sideways.vim'
        Plug 'AndrewRadev/splitjoin.vim'
        Plug 'michaeljsmith/vim-indent-object'
        Plug 'jeetsukumaran/vim-indentwise'
        Plug 'mattn/vim-xxdcursor'

        " Usability
        Plug 'scrooloose/nerdtree', {'on': ['NERDTree', 'NERDTreeFind']}
        Plug 'mbbill/undotree', {'on': 'UndotreeToggle'}
        Plug 'junegunn/fzf', { 'dir': '~/.local/share/fzf', 'do': './install --all' }
        Plug 'junegunn/fzf.vim'
        Plug 'junegunn/vim-peekaboo'
        Plug 'haya14busa/vim-asterisk'
        Plug 'easymotion/vim-easymotion'
        Plug 'tpope/vim-unimpaired'
        Plug 'ipwnponies/vim-agriculture'

        " Pretty
        Plug 'vim-airline/vim-airline'
        Plug 'sainnhe/sonokai'
        Plug 'haya14busa/incsearch.vim'
        Plug 'RRethy/vim-illuminate'
        Plug 'ryanoasis/vim-devicons'

        " IDE
        Plug 'ms-jpq/coq_nvim', {'commit': 'bb03037d7888b40e9bd205b0b05365dd94a5b06e', 'do': 'python -m coq deps'}
        Plug 'ms-jpq/coq.artifacts', {'commit': 'f8d60eec57f1aa63ef02e4194f806d0231d5d585'}
        Plug 'ms-jpq/coq.thirdparty', {'commit': '274eaaa1a0aec4d4b4a576af5895904e67d03c1a'}
        Plug 'neovim/nvim-lspconfig'
        Plug 'gfanto/fzf-lsp.nvim'
        Plug 'nvim-lua/plenary.nvim' " Dependency of fzf-lsp
    call plug#end()

" Plugin Custom Configurations:
    " Coq:
        " jump_to_mark is mapped to ctrl-l by default
        let g:coq_settings = {
            \ 'auto_start': v:true,
            \ 'keymap': {
                \ 'jump_to_mark': '<c-i>'
                \},
            \ }

        inoremap <silent><expr> <CR>    pumvisible() ? (complete_info().selected == -1 ? "\<C-e><CR>" : "\<C-y>") : "\<CR>"

    " fzf-lsp.nvim
        nmap gD :LspAction<cr>
        nmap gr :References<cr>

        " Add missing LSP command to fzf-lsp
        command Rename lua vim.lsp.buf.rename()
        command LspAction call s:LspAction()

        function s:LspAction()
            call fzf#run( fzf#wrap( {
                        \ 'source': ['definition', 'references', 'declaration', 'type_definition', 'implementation', 'hover', 'signature_help', 'code_action', 'formatting', 'execute_command', 'workspace_symbol', 'document_symbol', 'rename'],
                        \ 'sink': {i -> s:executeLua(i)},
                        \ }))
        endfunction

        function s:executeLua(action)
            execute 'lua vim.lsp.buf.' . a:action . '()'
        endfunction

    " GitGutter: Git status while editing files
        set updatetime=250
        if exists('&signcolumn') | set signcolumn=yes | endif
    " Vim Fugitive: Git operations in vim
        nnoremap <leader>gs :Gstatus<CR>
        nnoremap <leader>gg :Ggrep! -iP <cword>
        nnoremap <leader>gB :Git blame<cr>
        cabbrev Glgrep Glgrep -i
        cabbrev Ggrep Ggrep -i
        cabbrev Gdiffsplit Gdiffsplit @{u}...
        command! Gdifftool Git difftool --name-only @{u}...

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
                    \ 'python': ['black', 'isort'],
                    \ 'terraform': ['terraform'],
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
    " EasyMotion:
        let g:EasyMotion_use_upper = 1
        let g:EasyMotion_use_smartsign_us = 1
        let g:EasyMotion_smartcase = 1
        let g:EasyMotion_do_shade = 0
        let g:EasyMotion_enter_jump_first = 1
        let g:EasyMotion_keys = 'ASDGHKLQWERTYUIOPZXCVBNMFJ;'
        map ; <Plug>(easymotion-prefix)
        map S <Plug>(easymotion-sn)
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
        let g:qf_shorten_path = 0
    " Vim Agriculture:
        vmap <leader>* <Plug>RgRawVisualSelection
        nmap <leader>* <Plug>RgRawWordUnderCursor

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

    " Local overrides
    set exrc

    " Misc
    set pastetoggle=<f2>
    set hidden
    set backspace=2
    set modeline
    set mouse=a

    syntax enable
    filetype plugin on

" Colors:
    set termguicolors
    colorscheme sonokai
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

" Emulate exrc. Host-specific configurations
let s:init_local = fnamemodify($MYVIMRC, ':h') . '/init_local.vim'
if filereadable(s:init_local)
    execute 'source ' . s:init_local
endif

highlight LspReferenceRead  ctermbg=237 guibg=Green
highlight LspReferenceWrite ctermbg=237 guibg=Brown
highlight LspReferenceText guibg=#53575c

lua <<EOF
require'lspconfig'.tsserver.setup{
    detached = false,
    on_attach = function(client)
      require 'illuminate'.on_attach(client)
    end,
}
require'lspconfig'.pyright.setup{
    on_attach = function(client)
      require 'illuminate'.on_attach(client)
    end,
}
require'lspconfig'.bashls.setup{
    on_attach = function(client)
      require 'illuminate'.on_attach(client)
    end,
}
require'lspconfig'.dockerls.setup{
    on_attach = function(client)
      require 'illuminate'.on_attach(client)
    end,
}
require'lspconfig'.html.setup {
    capabilities = capabilities,
    filetypes = { "html", "javascriptreact", "typescriptreact" },
    on_attach = function(client)
    require 'illuminate'.on_attach(client)
    end,
}

local bufopts = { noremap=true, silent=true, buffer=bufnr }
vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
vim.keymap.set('n', '<leader>K', vim.lsp.buf.signature_help, bufopts)
vim.api.nvim_set_keymap('n', ']d', '<cmd>lua require"illuminate".next_reference{wrap=true}<cr>', {noremap=true})
vim.api.nvim_set_keymap('n', '[d', '<cmd>lua require"illuminate".next_reference{reverse=true,wrap=true}<cr>', {noremap=true})
EOF
