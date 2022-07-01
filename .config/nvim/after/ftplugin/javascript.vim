" Mapping
    " Arrow function stub
    iabbrev <buffer> fr () => {<CR>}
    iabbrev <buffer> debugger debugger; // eslint-disable-line

" Commands
command! FlowReveal execute printf('!yarn flow type-at-pos %s %s %s', @%, line('.'), col('.'))
