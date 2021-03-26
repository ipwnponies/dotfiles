# Abbreviations
abbr --global --add df      'df -h'
abbr --global --add du      'du -h --max-depth=1'
abbr --global --add j       'jobs'
abbr --global --add g       'grep -Pi --color=auto'
abbr --global --add pgrep   'pgrep -fau (whoami)'
abbr --global --add pkill   'pkill -fu (whoami)'
abbr --global --add kill    'kill -s TERM'
abbr --global --add fzfdo   'fzf | read -l fzf; and'
abbr --global --add less    'less -iR'
abbr --global --add netstat 'netstat --listening --program --numeric'
abbr --global --add jq      'jq --color-output --sort-keys'
abbr --global --add watch   'watch -cd -n 5'
abbr --global --add time    'time -f \'Total Time: %E\nExit Code: %x\''
abbr --global --add vd      'TERM=screen-256color vd'

# pytest
set -l pytest_args '--capture no --exitfirst --failed-first --testmon --tlf tests/'
abbr --global --add pytest  "pytest -vv $pytest_args"
abbr --global --add pytestw "pytest-watch -- $pytest_args"

# taskwarrior
abbr --global --add ta 'task +ACTIVE'
abbr --global --add tl 'task +LATEST annotate'
abbr --global --add tr 'task +READY'

set -l local_functions (dirname (status --current-filename))/abbr_local.fish
if test -e $local_functions
    source $local_functions
end
