# Installation of vim-plug plugins

if status --is-login; and status --is-interactive;
    # Async installation of plugins to speed up shell startup
    # stdin and stdout are redirected to the void, to signify this is non-interactive vim session
    fish --no-config -c "$EDITOR -u $HOME/.vimrc -c PlugInstall -c qa </dev/null >/dev/null 2>&1" &
end
