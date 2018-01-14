# Installation of vim-plug plugins

if status --is-login; and status --is-interactive;
    eval $EDITOR -c PlugInstall -c qa >/dev/null
end
