# Source common git functions from fish native git completions
set -l fish_install_dir (printf '%s/share/fish/completions/git.fish' (dirname (dirname (command -v fish))))
if test -f $fish_install_dir
    source $fish_install_dir
else
    printf "Could not load custom git completions!" >&2
    exit 1
end

complete -r -f -c git -n '__fish_git_using_command co' -a '(__fish_git_branches_fzf -r)' --description 'all branches'
complete -r -f -c git -n '__fish_git_using_command ci' -l fixup -a '(__fish_git_ci_fixup)' --description 'sha'
complete -r -f -c git -n '__fish_git_using_command stash' -a '(__fish_git_stash_show)' --description 'Stashes'

function __fish_git_branches_fzf -d 'Override the native fish function for getting local branches'
    set remote (test "$argv[1]" = '-r'; and echo '-a'; or echo '*')

    # Taken from fish shell git completions but changed git branch to only return local branches
    command git branch --list --no-color $remote 2>/dev/null | \
    # Filter out current branch
    string match -v '\**' | \
    # Ignore symbolic refs
    string match -r -v ' -> ' | \
    string trim | \
    # Short qualified name for remote branches. Noop for local branches
    string replace -r "^remotes/" "" | \
    fzf_complete --preview 'git log -1 {} --color=always' --tiebreak=begin --no-sort

    if test $status -ne 0
        git symbolic-ref HEAD --short
    end
end

function __fish_git_stash_show
    command git stash list --format=format:'%gd' | \
    fzf_complete --preview 'git stash show {} --color=always'
end

function __fish_git_ci_fixup
    command git log --pretty=oneline --abbrev-commit '@{u}..' | \
    fzf_complete --preview 'git show {1} --color=always' --with-nth 2.. --tiebreak begin,index --no-sort | \
    cut -d ' ' -f 1
end

set -l local_functions (dirname (status --current-filename))/git_local.fish
if test -e $local_functions
    source $local_functions
end
