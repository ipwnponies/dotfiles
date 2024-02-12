" python uses four-space indents
set tabstop=4
set softtabstop=0
set shiftwidth=0
set expandtab
iabbrev <buffer> pudb breakpoint() # noqa

let b:ale_linters_ignore = ['pylint']

" Add -> None to all pytest test cases
command TestReturnNone %substitute/\vdef test_.*(None)@<!\zs\ze:$/ -> None
