if status --is-interactive
    set --export _ZO_FZF_OPTS "$FZF_DEFAULT_OPTS --keep-right --border=rounded --no-sort"

    zoxide init fish --cmd cd | source
end
