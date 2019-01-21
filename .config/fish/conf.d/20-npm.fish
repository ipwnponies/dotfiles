# Installation of local npm library

set -l venv "$XDG_CONFIG_HOME/npm"
set PATH "$venv/node_modules/.bin" $PATH

if status --is-login; and status --is-interactive; and type -q npm;

    set logfile "$XDG_CACHE_HOME/npm"

    fish -c "
        mkdir -p (dirname $logfile)
        if not npm install --loglevel=error --prefix $venv >> $logfile
            echo 'Uh... that didn\'t work gud. So check out $logfile'
        end
    " &
end
