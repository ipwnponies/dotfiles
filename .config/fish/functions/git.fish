# These completions must be autoloaded because the command is autoloaded. Otherwise fish will fail
# to find git and won't load this completion
complete -f -c git -n '__fish_git_using_command co' -a '(__fish_git_branches)' --description 'Remote repo'

if test -e git_local.fish
    source git_local.fish
end
