# Configure plugin-expand

if status --is-interactive; and set -q OMF_PATH
    expand-word -p '^!$' -e 'printf "%s\n" $history'

    # Bash's ^foo^bar^ substitution. Supports sed syntax command
    expand-word -p '^s(.)..*\1.*$' -e '_expand_sed_history'
    function _expand_sed_history
        set sed_command (commandline -t)
        set delimiter (string sub --start 2 --length 1 $sed_command)
        set search_term (string split $delimiter $sed_command)[2]

        # Close sed command and add default option, global
        test (count (string match --all $delimiter $sed_command) -gt 2); and set sed_command $sed_command$delimiter'g'

        printf '%s\n' $history | grep $search_term | sed -e $sed_command
    end

    # Git merge expansion
    expand-word -p '^gitmer$' -e '_expand_gitmer'
    function _expand_gitmer
        # Suggest previous branch as default first candidate, then the rest of existing branches
        set -l branches (git rev-parse --abbrev-ref '@{-1}') (git for-each-ref --format '%(refname:short)' refs/heads/)
        # Provide optional suggestion for --no-ff
        printf 'git merge %s\n' $branches{,' --no-ff'}
    end
end
