# Installation of vim-plug plugins

if status --is-login; and status --is-interactive;
    eval $EDITOR -e -s -c PlugInstall -c qa
end
