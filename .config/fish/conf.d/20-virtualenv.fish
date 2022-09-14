# Installation of local virtualenv

set -l venv "$XDG_DATA_HOME/virtualenv"
fish_add_path --global $venv/bin

if status --is-login; and status --is-interactive; and type -q virtualenv;

    set requirements "$XDG_CONFIG_HOME/venv-update/requirements.txt"
    set requirements_bootstrap "$XDG_CONFIG_HOME/venv-update/requirements-bootstrap.txt"
    set logfile "$XDG_CACHE_HOME/venv-update/log"

    set system_python (env --ignore-environment type --path python3.9)

    # Run venv-update in background because most of the time, this is noop
    # When it does change something, we only need the side effects (new programs installed)
    fish -c "
        mkdir -p (dirname $logfile)
        $system_python -m venv $venv
        $venv/bin/pip install -r $requirements -r $requirements_bootstrap
    " | ts >> $logfile &
end

# Add pyenv shims if this system supports it
if type -q pyenv; and begin
        # Always use pyenv for interactive shells
        # Allow pyenv for non-interactive (shell scripts) but skip vim non-interactive, invoked frequently from vim plugins
        status --is-interactive; or not set -q VIMRUNTIME
    end

    # Adds pyenv command and autocompletion
    pyenv init --no-rehash - | source

    # Auto-activates pyenv. This sets up env like normal virtualenv, sidestepping pyenv shim magic
    pyenv virtualenv-init - | source
end
