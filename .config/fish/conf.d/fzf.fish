if status --is-login; and status --is-interactive
    if type -q fzf
        set -gx FZF_DEFAULT_OPTS "--reverse --select-1 --exit-0 \
        --border --height 40% --min-height 10 --margin 1,5 --inline-info \
        --bind pgdn:preview-page-down,pgup:preview-page-up,change:top,ctrl-s:toggle-sort"
    end
end
