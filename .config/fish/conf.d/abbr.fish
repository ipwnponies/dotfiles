# Abbreviations
abbr --add g        'command grep -Pi --color=auto'
abbr --add df       'df -h'
abbr --add du       'du -h --max-depth=1'
abbr --add j        'jobs'
abbr --add g        'grep -Pi --color=auto'
abbr --add ps       'ps -f'
abbr --add pgrep    'pgrep -fau (whoami)'
abbr --add pkill    'pkill --fu (whoami)'
abbr --add kill     'kill -s TERM'
abbr --add fzfdo    'fzf | read -l fzf; and'
abbr --add fzf      'fzf --border --height 40% --min-height 10 --margin 1,5 --reverse --inline-info -1 -0 --bind change:top'
abbr --add pytest   'pytest --verbose --capture no --pdbcls IPython.terminal.debugger:TerminalPdb'
abbr --add less     'less -iR'
abbr --add netstat  'netstat --listening --program --numeric'

set local_functions (dirname (status --current-filename))/abbr_local.fish
if test -e $local_functions
    source $local_functions
end
