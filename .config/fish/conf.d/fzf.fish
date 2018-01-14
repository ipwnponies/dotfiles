if status --is-login; and status --is-interactive
    if type -q fzf
        set -gx FZF_DEFAULT_OPTS '--border --height 40% --min-height 10 --margin 1,5 --reverse -1 -0 --inline-info --bind pgdn:preview-page-down,pgup:preview-page-up,change:top'
    end
end
