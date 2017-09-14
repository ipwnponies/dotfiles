# These completions must go in functions, not completions.
# They rely on git functions that must be autoloaded first.
complete -r -f -c git -n '__fish_git_using_command co' -a '(__fish_git_co_branches)' --description 'Branches'
function __fish_git_co_branches
    set query (commandline -t)

    # Taken from fish shell git completions but changed git branch to only return local branches
    command git branch --no-color -a ^/dev/null | \
    string match -v '\* (*)' | \
    string match -r -v ' -> ' | \
    string trim -c "* " | \
    string replace -r "^remotes/" "" | \
    fzf --border --height 40% --min-height 10 --margin 1,5 --reverse --inline-info --preview 'git log -1 {}' --query $query

    if test $status -ne 0
        git symbolic-ref HEAD --short
    end
end

set local_functions (dirname (status --current-filename))/git_local.fish
if test -e $local_functions
    source $local_functions
end
