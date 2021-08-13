" python uses four-space indents
set tabstop=4
set softtabstop=0
set shiftwidth=0
set expandtab

let b:ale_fixers = ['black', 'isort']
let b:ale_fix_on_save = 1
iabbrev <buffer> pudb import pudb; pu.db # noqa
