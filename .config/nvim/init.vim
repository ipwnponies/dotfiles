" Vim Plug: Bootstrap vim-plug for fresh vim install
    if !filereadable(expand('~/.vim/autoload/plug.vim'))
      silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
      autocmd! VimEnter * PlugInstall
    endif

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
    " Fzf:
        nnoremap <leader>ff :FZF<CR>
        nnoremap <leader>fg :GFiles<CR>
        nnoremap <leader>fl :Lines<CR>
        nnoremap <leader>/ :BLines<CR>
        nnoremap <leader>fc :Commands<CR>
        nnoremap <leader>fh :Helptags<CR>
        nnoremap <leader>fC :BCommits<CR>

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
    " Hop (replaces EasyMotion):
        map ; <Plug>(hop-prefix)
        map <Plug>(hop-prefix)/ <Cmd>HopPatternMW<CR>
        map <Plug>(hop-prefix)w <Cmd>HopWordAC<CR>
        map <Plug>(hop-prefix)W <Cmd>HopWordBC<CR>
        map <Plug>(hop-prefix)c <Cmd>HopCamelCaseAC<CR>
        map <Plug>(hop-prefix)C <Cmd>HopCamelCaseBC<CR>
        map <Plug>(hop-prefix)f <Cmd>HopChar1CurrentLine<CR>
        map <Plug>(hop-prefix)j <Cmd>HopLineStartMW<CR>
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
    " Vim Agriculture:
        vmap <leader>* <Plug>RgRawVisualSelection
        nmap <leader>* <Plug>RgRawWordUnderCursor

    " Lazygit
        nnoremap <leader>ll : LazyGitCurrentFile<CR>
        nnoremap <leader>lc :LazyGitFilterCurrentFile<CR>

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

require("fidget").setup {
  -- options
}

local hop = require 'hop'
hop.setup({uppercase_labels=true })

require('neodev').setup()

local cmp = require 'cmp'

local luasnip = require 'luasnip'
require('luasnip.loaders.from_vscode').lazy_load()
luasnip.config.setup {}

local cmp_buffer = require('cmp_buffer')
cmp.setup {
  snippet = {
    expand = function(args)
    luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert {
    ['<C-n>'] = cmp.mapping.select_next_item(),
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete {},
    ['<CR>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
    },
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_locally_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.locally_jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<C-g>'] = cmp.mapping(function(fallback)
      vim.api.nvim_feedkeys(vim.fn['copilot#Accept'](vim.api.nvim_replace_termcodes('<Tab>', true, true, true)), 'n', true)
    end)
  },
  sources = {
    {
      name = 'nvim_lsp',
    },
    { name = 'nvim_lsp_signature_help' },
    {
      name = 'buffer',
      keyword_length=5,
      max_item_count=5,
      option = {
        get_bufnrs = function()
          local bufs = {}
          for _, win in ipairs(vim.api.nvim_list_wins()) do
            bufs[vim.api.nvim_win_get_buf(win)] = true
          end
          return vim.tbl_keys(bufs)
        end
      },
    },
    { name = 'luasnip' },
  },
  matching = {
    -- The value without fuzziness is multi-word completion
    disallow_fuzzy_matching = false,
    disallow_fullfuzzy_matching = false,
    -- Needs to match on prefix of components. Components are tokenized vim words
    disallow_partial_fuzzy_matching = true,
    -- Need to match prefix of first word. To search later, need to break prefix match and fuzzy on first word. Super weird behaviour.
    disallow_partial_matching = false,
    -- completion needs first letter to match: https://github.com/hrsh7th/nvim-cmp/blob/04e0ca376d6abdbfc8b52180f8ea236cbfddf782/lua/cmp/matcher.lua#L98
    -- this is special case of partial fuzzy matching
    disallow_prefix_unmatching = false,
  },
}
cmp.setup.cmdline({ '/', '?' }, {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = 'nvim_lsp_document_symbol', keyword_length = 2, max_item_count = 5 },
    { name = 'buffer', keyword_length = 2, max_item_count = 5 },
  }
})
  cmp.setup.cmdline(":", {
    mapping = cmp.mapping.preset.cmdline(),
    --window = { completion = cmp.config.window.bordered({ col_offset = 0 }) },
    --formatting = { fields = { "abbr" } },
    sources = cmp.config.sources({
      { name = "cmdline", keyword_length = 2, max_item_count = 8 },
      { name = "path" },
      { name = "buffer", keyword_length = 3, max_item_count = 5 },
    }),
  })
require'hop'.setup({uppercase_labels=true })

vim.g.firenvim_config = {
    localSettings = {
        [".*"] = {
            selector = "textarea, input",
            takeover = "never"
        }
    }
}

function SetupFirenvim()
    -- Only for firenvim browser extension
    -- This minimizes the UI due to limited real estate

    if not vim.g.started_by_firenvim then
      return
    end

    vim.opt.guifont = "FiraCode_Nerd_Font_Mono:h8"
    vim.w.airline_disable_statusline = 1
    vim.opt.laststatus = 0
    vim.opt.showtabline = 0
    vim.opt.number = false
    vim.opt.cursorline = false
    vim.opt.signcolumn = "no"

    local id = vim.api.nvim_create_augroup("ExpandLinesOnTextChanged", { clear = true })
    vim.api.nvim_create_autocmd({"TextChanged", "TextChangedI"}, {
      group = id,
      callback = function(ev)
        local max_height = 40

        -- To avoid constant jitters, we only contract when the content is much smaller than window
        -- As we get to single-digit line count, this is effectively 1:1 between content and window
        local shrink = {
            threshold = 0.7, -- Avoids constant jitters
            buffer = 0.9, -- Shrink such that content is 90% of height
        }
        local height = vim.api.nvim_win_text_height(0, {}).all

        if height > vim.o.lines and height < max_height then
          vim.o.lines = height
        elseif height < vim.o.lines * shrink.threshold  then
          -- Shrink with hysteresis
          vim.o.lines = math.floor(height / shrink.buffer)
        end
      end
    })
end

vim.api.nvim_create_autocmd({ "UIEnter", "FileType" }, {
  pattern = "text",
  callback = function()
    SetupFirenvim()
  end,
})
EOF
