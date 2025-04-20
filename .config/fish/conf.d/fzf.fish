if status --is-interactive; and type -q fzf
    set -gx FZF_DEFAULT_OPTS "--reverse --select-1 --exit-0 \
    --border double --height 40% --min-height 10 --margin 1,5 --info inline \
    --bind pgdn:preview-page-down,pgup:preview-page-up,change:top,ctrl-s:toggle-sort,ctrl-a:toggle-all"

    fzf --fish | source
end
