# These completions must be autoloaded because the git function is autoloaded. Otherwise fish will fail
# to find the command and get to loading this completion.
complete -f -c git -n '__fish_git_using_command co' -a '(__fish_git_unique_remote_branches)' --description 'Remote Branch'
complete -f -c git -n '__fish_git_using_command co' -a '(__fish_git_local_branches)' --description 'Local Branch'
function __fish_git_local_branches
    # Taken from fish shell git completions but changed git branch to only return local branches
    command git branch --no-color $argv ^/dev/null | string match -v '\* (*)' | string match -r -v ' -> ' | string trim -c "* " | string replace -r "^remotes/" ""
end

set local_functions (dirname (status --current-filename))/git_local.fish
if test -e $local_functions
    source $local_functions
end
