if status --is-login; and status --is-interactive
    if not test -d $XDG_CONFIG_HOME/fzf
        nvim -c 'silent! PlugInstall fzf' -c 'qa'
    end
end
