if status --is-login; and status --is-interactive
    set venv "$XDG_CONFIG_HOME/virtualenv"
    set venv_update "$XDG_CONFIG_HOME/venv-update/venv-update"
    set requirements "$XDG_CONFIG_HOME/venv-update/requirements.txt"
    set logfile "$XDG_CACHE_HOME/venv-update/log"
    mkdir -p (dirname $logfile)

    echo 'venv-updating...'

    set install_script "
        if $venv_update venv= -p python3 $venv install= -r $requirements >> $logfile
            set fish_user_paths $fish_user_paths '$venv/bin'
        else
            echo 'Uh... that didn\'t work gud. So check out $logfile'
        end
        "
    # Hacky workaround to subshell
    fish -c $install_script &
end
