if status --is-interactive
    set --export _ZO_FZF_OPTS "$FZF_DEFAULT_OPTS --keep-right --border=rounded"

    zoxide init fish --cmd cd | source

    # fzf-widget calls `cd -- $argv` and zoxide doesn't understand '--'
    function cd --wraps=__zoxide_z --description 'Override default zoxide cd alias'
        if test (count $argv) -gt 0; and test $argv[1] = '--'
            set --erase argv[1]
        end
        __zoxide_z $argv
    end
end
