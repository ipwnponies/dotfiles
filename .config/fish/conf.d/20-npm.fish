# Installation of local npm library

set -l venv "$XDG_CONFIG_HOME/npm"
fish_add_path --global $venv/node_modules/.bin

if status --is-login; and status --is-interactive; and type -q npm;

    set npm_version (string split '.' (npm --version))
    if not test (count $npm_version) -eq 3; or not test $npm_version[1] -ge 7
        echo 'npm 7+ is required' >&2
        exit
    end

    set logfile "$XDG_CACHE_HOME/npm"

    fish -c "
        mkdir -p (dirname $logfile)
        if not npm install --lockfile-version 3 --loglevel=error --prefix $venv >> $logfile 2>&1
            echo 'Uh... that didn\'t work gud. So check out $logfile'
        end
    " &
end
