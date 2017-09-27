# Configure plugin-expand

if status --is-interactive; and set -q OMF_PATH
    expand-word -p '^!$' -e 'printf "%s\n" $history'

    # Bash's ^foo^bar^ substitution
    expand-word -p '^s/..*/.*$' -e 'echo -n "$history[1]" | sed -e (commandline -t)/g'

    # Bash's !! history substitution
    expand-word -p '^!!$' -e 'echo -n $history[1]'

    # Bash's !-n history substitution
    expand-word -p '^!-[0-9]$' -e 'echo -n $history[(string sub -s -1 (commandline -t))]'

    # Git merge expansion
    expand-word -p '^gitmer$' -e '_expand_gitmer'
    function _expand_gitmer
        set -l branches (git for-each-ref --format '%(refname:short)' refs/heads/)
        # Provide optional suggestion for --no-ff
        printf 'git merge --no-edit %s\n' $branches{' --no-ff',}
    end
end
