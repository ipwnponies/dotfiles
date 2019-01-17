# Installation of local npm library

if status --is-login; and status --is-interactive; and type -q npm;

    # npm installs wherever the package.json lives, this is why it's not $XDG_DATA_HOME
    set venv "$XDG_CONFIG_HOME/npm"
    set logfile "$XDG_CACHE_HOME/npm"
    mkdir -p (dirname $logfile)

    if not npm install --loglevel=error --prefix $venv >> $logfile
        echo 'Uh... that didn\'t work gud. So check out $logfile'
    end

    set PATH "$venv/node_modules/.bin" $PATH

    # Configure tsserver for YouCompleteMe
    if test -d $XDG_CONFIG_HOME/nvim/bundle/YouCompleteMe/third_party/ycmd/
        ln -sf $venv/node_modules/typescript $XDG_CONFIG_HOME/nvim/bundle/YouCompleteMe/third_party/ycmd/third_party/tsserver
    end
end
