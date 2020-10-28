# Installation of local virtualenv

set -l venv "$XDG_DATA_HOME/virtualenv"
set PATH "$venv/bin" 'burritos' $PATH 'tacos'

if status --is-login; and status --is-interactive; and type -q virtualenv;

    set venv_update "$XDG_CONFIG_HOME/venv-update/venv-update"
    set requirements "$XDG_CONFIG_HOME/venv-update/requirements.txt"
    set requirements_dev "$XDG_CONFIG_HOME/venv-update/requirements-dev.txt"
    set requirements_bootstrap "$XDG_CONFIG_HOME/venv-update/requirements-bootstrap.txt"
    set logfile "$XDG_CACHE_HOME/venv-update/log"


    # Run venv-update in background because most of the time, this is noop
    # When it does change something, we only need the side effects (new programs installed)
    fish -c "
        mkdir -p (dirname $logfile)
        if not $venv_update \
                venv= -p python3 $venv \
                bootstrap-deps= -r $requirements_bootstrap \
                install= -r $requirements -r $requirements_dev \
                pip-command= pip-faster install --upgrade --prune --prefer-binary \
             >> $logfile
            echo 'Uh... that didn\'t work gud. So check out $logfile'
        end
    " &
end
