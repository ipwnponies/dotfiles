function extend
    # Erase automatic completions for git aliases. This prevents interference with fzf single output
    set --erase __fish_git_alias_co
    complete -r -f -c git -n '__fish_git_using_command co' -a '(__fish_git_branches_fzf)' --description 'all branches'
    complete -r -f -c git -n '__fish_git_using_command ci' -l fixup -a '(__fish_git_ci_fixup)' --description 'sha'

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

    complete -f -c git -n '__fish_git_using_command forgit' -a 'add blame branch_delete checkout_branch checkout_commit checkout_file checkout_tag cherry_pick cherry_pick_from_branch clean diff fixup ignore log rebase reset_head revert_commit stash_show stash_push'
    complete -f -c git -n __fish_git_needs_command -a forgit -d 'Git, powered by fzf'
end

function extend_local
    set local_functions (dirname (status --current-filename))/git_local.fish
    if test -e $local_functions
        source $local_functions
    end

end

completions_load_upstream (status filename)
extend
completions_extend_local (status filename)
