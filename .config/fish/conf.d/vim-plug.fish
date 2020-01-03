# Installation of vim-plug plugins

if status --is-login; and status --is-interactive;

    set coc_extensions coc-css coc-flow coc-html coc-json coc-python coc-tsserver coc-yaml

    # Async installation of plugins to speed up shell startup
    # stdin and stdout are redirected to the void, to signify this is non-interactive vim session
    fish -c "$EDITOR -u $HOME/.vimrc -c PlugInstall -c qa </dev/null >/dev/null 2>&1" &
    fish -c "$EDITOR -u $HOME/.vimrc -c 'CocInstall -sync $coc_extensions' -c qa </dev/null >/dev/null 2>&1" &
end
