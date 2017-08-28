if status --is-login; and status --is-interactive; and not type -q fzf
    # Install fzf via vim-plug
    eval $EDITOR -c \'silent! PlugInstall fzf\' -c \'qa\'
end
