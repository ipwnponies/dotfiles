" Mapping
    " Arrow function stub
    iabbrev <buffer> fr () => {<CR>}
    iabbrev <buffer> debugger debugger; // eslint-disable-line

" Commands
command! FlowReveal execute printf('!yarn flow type-at-pos %s %s %s', @%, line('.'), col('.'))

" Plugin Settings
    " ALE:
    let b:ale_fixers = [ 'eslint' ]
    let b:ale_fix_on_save = 1
    let b:ale_linters_ignore = [ 'tsserver' ]
