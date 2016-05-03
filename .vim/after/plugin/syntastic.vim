let g:syntastic_always_populate_loc_list=1 "always make :lw available
let g:syntastic_loc_list_height=3 "The default height of the :Errors pane
let g:syntastic_aggregate_errors=1
" see also: https://github.com/scrooloose/syntastic/issues/978
let g:syntastic_python_checkers=['python', 'flake8', 'pylint', 'py3kwarn', 'pylama']
