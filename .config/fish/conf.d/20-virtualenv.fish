# Installation of local virtualenv

type --query --no-functions pyenv; or exit

test -n "$PYENV_ROOT"; or set -gx PYENV_ROOT $HOME/.pyenv

set -g venv "$XDG_DATA_HOME/virtualenv"
fish_add_path --global $venv/bin

# Set pyenv PATH through fish_user_paths, which has higher precedence than raw PATH
fish_add_path --global $PYENV_ROOT/shims

# The pyenv instructions use `pyenv init - |  source`. While convenient, it's poorly optimized:
# - it spins up subshell to evaluate. Which is mostly static
# - loads shell completions, via source. Not needed if you set up paths correctly
# By inlining it here, we reduce costs by 30% or 100 ms
function pyenv-init --description 'Stripped down, lightweight pyenv init'
    # pyenv init -
    set -gx PYENV_SHELL fish

    # pyenv shim magic only resolves to versioned commands; it does not set up VIRTUAL_ENV.
    # Dropping the fish_prompt hook means VIRTUAL_ENV is no longer set automatically, so
    # bobthefish's virtualenv prompt segment (keyed off $VIRTUAL_ENV, see bobthefish.fish)
    # no longer appears on its own. Use direnv (.config/fish/conf.d/direnv.fish) for cases
    # that need VIRTUAL_ENV set (and the prompt segment back), or run `pyenv activate`
    # manually (pair it with `pyenv deactivate` when done - nothing unwinds it automatically,
    # and a lingering venv bin/ on PATH shadows the pyenv shims in unrelated directories).
    # pyenv virtualenv-init - (fish_prompt hook intentionally omitted, see above; keep it
    # omitted when regenerating this block from `pyenv virtualenv-init -`)
    while set index (contains -i -- $PYENV_ROOT/plugins/pyenv-virtualenv/shims $PATH)
        set -eg PATH[$index]
    end
    set -gx PATH $PYENV_ROOT/plugins/pyenv-virtualenv/shims $PATH

    set -gx PYENV_VIRTUALENV_INIT 1

    function pyenv
        set command $argv[1]
        set -e argv[1]

        switch "$command"
            case activate deactivate rehash shell
                source (pyenv "sh-$command" $argv|psub)
            case "*"
                command pyenv "$command" $argv
        end
    end
end

function install
    if test ! -d $venv
        echo "Creating virtualenv in $venv" >&2
        python3 -m venv $venv
    end

    set -l stamp $XDG_STATE_HOME/venv-update/install.stamp
    if is_expired $stamp $XDG_CONFIG_HOME/venv-update/pyproject.toml $XDG_CONFIG_HOME/venv-update/poetry.lock
        mkdir -p (dirname $stamp)

        set logfile "$XDG_CACHE_HOME/venv-update/log"
        mkdir -p (dirname $logfile)

        # Poetry will install into activated virtualenv. No other way to tell poetry to target a directory
        set -x VIRTUAL_ENV $venv
        fish --no-config -c "
            poetry sync --project $XDG_CONFIG_HOME/venv-update/ | ts >>$logfile
            test \$pipestatus[1] -eq 0; and touch $stamp
        " &
    end

    set -l pyenv_virtualenv_plugin $PYENV_ROOT/plugins/pyenv-virtualenv
    test -d $pyenv_virtualenv_plugin; or git clone --branch v1.4.0 --depth 1 https://github.com/pyenv/pyenv-virtualenv.git $pyenv_virtualenv_plugin
end

pyenv-init
status --is-login; and install
