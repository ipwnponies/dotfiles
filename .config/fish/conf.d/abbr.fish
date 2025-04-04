# Clean slate, ensure abbreviations are under version control
abbr --erase (abbr --list)

# Abbreviations
abbr --global --add df         'df -h'
abbr --global --add du         'du -h --max-depth=1'
abbr --global --add fswatch    'fswatch --event Renamed --exclude ".*" --include \'\' .'
abbr --global --add fzfdo      'fzf | read -l fzf; and'
abbr --global --add g          'grep -Pi --color=auto'
abbr --global --add histdelete "printf '%s ' (seq 0) | history delete --"
abbr --global --add j          'jobs'
abbr --global --add jiq        'jiq -q'
abbr --global --add jq         'jq --color-output --sort-keys'
abbr --global --add kill       'kill -s TERM'
abbr --global --add less       'less -iR'
abbr --global --add ls         'eza'
abbr --global --add ll         'eza -l'
abbr --global --add la         'eza -la'
abbr --global --add netstat    'netstat --listening --program --numeric'
abbr --global --add pgrep      'pgrep -fau (whoami)'
abbr --global --add pkill      'pkill -fu (whoami)'
abbr --global --add pstree     'pstree -g 3'
abbr --global --add time       'time -f \'Total Time: %E\nExit Code: %x\''
abbr --global --add vd         'TERM=screen-256color vd'
abbr --global --add watch      'watch -cd -n 5'

# pytest
set -l pytest_args '--capture no --exitfirst --failed-first --testmon tests/'
abbr --global --add pytest  "pytest -vv $pytest_args"
abbr --global --add pytestw "pytest-watch -- $pytest_args"

# taskwarrior
abbr --global --add ta 'task +ACTIVE'
abbr --global --add tl 'task +LATEST edit'
abbr --global --add tr 'task +READY'

set -l local_functions (dirname (status --current-filename))/abbr_local.fish
if test -e $local_functions
    source $local_functions
end
