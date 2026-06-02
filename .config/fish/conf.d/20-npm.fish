# Installation of local npm library

function install
    set venv $argv[1]

    set logfile "$XDG_CACHE_HOME/npm"
    fish --no-config -c "
        mkdir -p (dirname $logfile)
        if not npm ci --lockfile-version 3 --loglevel=error --prefix $venv >> $logfile 2>&1
            echo 'Uh... that didn\'t work gud. So check out $logfile'
        end
    " &
end

function main
    set venv "$XDG_CONFIG_HOME/npm"
    fish_add_path --global $venv/node_modules/.bin

    status --is-login; and install $venv
end

main
