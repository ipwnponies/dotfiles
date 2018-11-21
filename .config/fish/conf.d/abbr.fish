# Abbreviations
abbr --add g        'command grep -Pi --color=auto'
abbr --add df       'df -h'
abbr --add du       'du -h --max-depth=1'
abbr --add j        'jobs'
abbr --add g        'grep -Pi --color=auto'
abbr --add ps       'ps -f'
abbr --add pgrep    'pgrep -fau (whoami)'
abbr --add pkill    'pkill -fu (whoami)'
abbr --add kill     'kill -s TERM'
abbr --add fzfdo    'fzf | read -l fzf; and'
abbr --add less     'less -iR'
abbr --add netstat  'netstat --listening --program --numeric'
abbr --add jq       'jq --color-output --sort-keys'
abbr --add watch    'watch -cd -n 5'

set -l pytest_args  '-vv --capture no --exitfirst --failed-first tests/'
abbr --add pytest   "pytest $pytest_args"
abbr --add pytestw  "pytest-watch -- $pytest_args"

set -l local_functions (dirname (status --current-filename))/abbr_local.fish
if test -e $local_functions
    source $local_functions
end
