# Installation of local virtualenv

if status --is-login; and status --is-interactive; and type -q virtualenv;

    set venv "$XDG_DATA_HOME/virtualenv"
    set venv_update "$XDG_CONFIG_HOME/venv-update/venv-update"
    set requirements "$XDG_CONFIG_HOME/venv-update/requirements.txt"
    set requirements_dev "$XDG_CONFIG_HOME/venv-update/requirements-dev.txt"
    set logfile "$XDG_CACHE_HOME/venv-update/log"

    set install_script "
        echo 'venv-updating...'

        mkdir -p (dirname $logfile)
        if not $venv_update venv= -p python3 $venv install= -r $requirements -r $requirements_dev >> $logfile
            echo 'Uh... that didn\'t work gud. So check out $logfile'
        end
        "
    # Hacky workaround to subshell
    fish -c $install_script &
    set PATH "$venv/bin" $PATH
end
