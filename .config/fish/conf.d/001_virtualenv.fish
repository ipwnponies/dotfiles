if status --is-interactive
    set venv "$XDG_CONFIG_HOME/virtualenv"
    set venv_update "$XDG_CONFIG_HOME/venv-update/venv-update"
    set requirements "$XDG_CONFIG_HOME/venv-update/requirements.txt"
    set logfile "$XDG_CACHE_HOME/venv-update/log"

    echo 'venv-updating...'

    if eval $venv_update venv= -p python3 $venv install= -r $requirements >> $logfile
        set PATH "$venv/bin" $PATH
    else
        echo "Uh... that didn't work gud. So check out $logfile"
    end
end
