# Installation of local npm library

set -l venv "$XDG_CONFIG_HOME/npm"
fish_add_path --global $venv/node_modules/.bin

if status --is-login; and status --is-interactive; and type -q npm;

    set logfile "$XDG_CACHE_HOME/npm"

    fish -c "
        mkdir -p (dirname $logfile)
        if not npm install --loglevel=error --prefix $venv >> $logfile 2>&1
            echo 'Uh... that didn\'t work gud. So check out $logfile'
        end
    " &
end
