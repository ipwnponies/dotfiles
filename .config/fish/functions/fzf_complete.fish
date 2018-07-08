# A fzf filter (in the unix sense) for completions. Replaces the default completion search and filtering with
# a fzf-powered variant. This shines when substring matching is not productive on completion candidates compared to
# fuzzy matching. This is a generalized form of the fzf keybinding for file completion (ctrl-t) or history search
# (ctrl-r).
#
# Example of replacing default cd completion for navigating dirs:
# complete -c cd -a "(ls | __fzf_complete)"
function fzf_complete --description "Prints values passed as args or through stdin for completion through fzf, if available. This can be disabled by using DISABLE_FZF_COMPLETE"
    # Allow for fallback to native behaviour if fzf is not available or disabled
    if type -q fzf; and not set -q DISABLE_FZF_COMPLETE
        set  -l last_arg (string trim (commandline -t))
        cat | fzf --query="$last_arg" $argv
    else
        cat
    end
end
