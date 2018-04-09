# Installation of vim-plug plugins

if status --is-login; and status --is-interactive;
    eval $EDITOR -E -s -u $HOME/.vimrc -c PlugInstall -c qa >/dev/null
end
