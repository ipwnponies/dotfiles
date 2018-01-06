# Source common git functions from fish native git completions
source /usr/share/fish/completions/git.fish

complete -r -f -c git -n '__fish_git_using_command co' -a '(__fish_git_branches_fzf -r)' --description 'all branches'
complete -r -f -c git -n '__fish_git_using_command ci' -l fixup -a '(__fish_git_ci_fixup)' --description 'sha'
complete -r -f -c git -n '__fish_git_using_command stash' -a '(__fish_git_stash_show)' --description 'Stashes'

function __fish_git_branches_fzf -d 'Override the native fish function for getting local branches'
    set query (commandline -t)
    set remote (test "$argv[1]" = '-r'; and echo '-a'; or echo '*')

    # Taken from fish shell git completions but changed git branch to only return local branches
    command git branch --list --no-color $remote ^/dev/null | \
    # Filter out current branch
    string match -v '\**' | \
    # Ignore symbolic refs
    string match -r -v ' -> ' | \
    string trim | \
    # Short qualified name for remote branches. Noop for local branches
    string replace -r "^remotes/" "" | \
    fzf --preview 'git log -1 {} --color=always' --query $query --tiebreak=end,index

    if test $status -ne 0
        git symbolic-ref HEAD --short
        echo jngu_wtf
    end
end

function __fish_git_stash_show
    command git stash list --format=format:'%gd' | \
    fzf --preview 'git stash show {} --color=always'
end

function __fish_git_ci_fixup
    command git log --pretty=oneline --abbrev-commit | \
    fzf --preview 'git show (echo {} | cut -d " " -f 1) --color=always' | \
    cut -d ' ' -f 1
end

set local_functions (dirname (status --current-filename))/git_local.fish
if test -e $local_functions
    source $local_functions
end
