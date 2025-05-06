# Installation of local virtualenv

function main
end

function install
    set venv "$XDG_DATA_HOME/virtualenv"
    fish_add_path --global $venv/bin

    if test ! -d $venv
        echo "Creating virtualenv in $venv" >&2
        python3 -m venv $venv
    end

    set logfile "$XDG_CACHE_HOME/venv-update/log"
    mkdir -p (dirname $logfile)

    # Poetry will install into activated virtualenv. No other way to tell poetry to target a directory
    set -x VIRTUAL_ENV $venv
    poetry install --project $XDG_CONFIG_HOME/venv-update/ | ts >> $logfile &

    # Set pyenv PATH through fish_user_paths, which has higher precedence than raw PATH
    fish_add_path (pyenv root)/shims

    set pyenv_virtualenv_plugin (pyenv root)/plugins/pyenv-virtualenv
    test -d $pyenv_virtualenv_plugin; or git clone https://github.com/pyenv/pyenv-virtualenv.git $pyenv_virtualenv_plugin

end

status --is-login; and install
status --is-interactive; and main
