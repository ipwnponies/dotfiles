# Configure plugin-expand

if status --is-interactive; and set -q OMF_PATH
    expand-word -p '^!$' -e 'printf "%s\n" $history'

    # Bash's ^foo^bar^ substitution
    expand-word -p '^s/..*/.*$' -e 'printf "%s\n" $history | sed -e (commandline -t)/g'

    # Git merge expansion
    expand-word -p '^gitmer$' -e '_expand_gitmer'
    function _expand_gitmer
        set -l branches (git for-each-ref --format '%(refname:short)' refs/heads/)
        # Provide optional suggestion for --no-ff
        printf 'git merge --no-edit %s\n' $branches{' --no-ff',}
    end
end
