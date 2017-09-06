# Installation of local npm library

if status --is-login; and status --is-interactive; and type -q npm;

    set venv "$XDG_DATA_HOME/npm"
    set package_json "$XDG_CONFIG_HOME/npm"
    set logfile "$XDG_CACHE_HOME/npm"
    mkdir -p (dirname $logfile)

    set install_script "
        echo 'npm updating...'

        if not npm install --loglevel=error --prefix $venv $package_json >> $logfile
            echo 'Uh... that didn\'t work gud. So check out $logfile'
        end
        "
    # Hacky workaround to subshell
    fish -c $install_script &
    set PATH "$venv/node_modules/.bin" $PATH
end
