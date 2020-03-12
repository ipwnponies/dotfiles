" python uses four-space indents
set tabstop=4
set softtabstop=0
set shiftwidth=0
set expandtab

let b:ale_fixers = ['black']
 
iabbrev <buffer> pudb import pudb; pu.db # noqa
