# Installation of local virtualenv

function main
    set venv "$XDG_DATA_HOME/virtualenv"
    fish_add_path --global $venv/bin

    if status --is-login; and status --is-interactive; and type -q virtualenv;
        if not test -e $venv -a -d $venv
            echo "Creating virtualenv in $venv" >&2
            python3 -m venv $venv
        end

        set logfile "$XDG_CACHE_HOME/venv-update/log"
        mkdir -p (dirname $logfile)

        # Poetry will install into activated virtualenv. No other way to tell poetry to target a directory
        set -x VIRTUAL_ENV $venv
        poetry install --project $XDG_CONFIG_HOME/venv-update/ | ts >> $logfile
    end

    # Add pyenv shims if this system supports it
    if type -q pyenv; and not set -q POETRY_ACTIVE; and begin
        # Always use pyenv for interactive shells
        # Allow pyenv for non-interactive (shell scripts) but skip vim non-interactive, invoked frequently from vim plugins
        status --is-interactive; or not set -q VIMRUNTIME
        end

        # Adds pyenv command and autocompletion
        pyenv init --no-rehash - | source

        # Auto-activates pyenv. This sets up env like normal virtualenv, sidestepping pyenv shim magic
        pyenv virtualenv-init - | source

        # Set pyenv PATH through fish_user_paths, which has higher precedence than raw PATH
        fish_add_path (pyenv root)/shims


        set pyenv_virtualenv_plugin (pyenv root)/plugins/pyenv-virtualenv
        test -d $pyenv_virtualenv_plugin; or git clone https://github.com/pyenv/pyenv-virtualenv.git $pyenv_virtualenv_plugin
    end
end

main
