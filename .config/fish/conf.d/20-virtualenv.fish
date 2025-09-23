# Installation of local virtualenv

# The pyenv instructions use `pyenv init - |  source`. While convenient, it's poorly optimized:
# - it spins up subshell to evaluate. Which is mostly static
# - loads shell completions, via source. Not needed if you set up paths correctly
# By inlining it here, we reduce costs by 30% or 100 ms
function pyenv-init --description 'Stripped down, lightweight pyenv init'

    # pyenv init -
    while set pyenv_index (contains -i -- "/Users/jnguyen/.pyenv/shims" $PATH)
        set -eg PATH[$pyenv_index]
    end
    set -gx PATH '/Users/jnguyen/.pyenv/shims' $PATH
    set -gx PYENV_SHELL fish
    command pyenv rehash 2>/dev/null

    # Auto-activates pyenv virtualenvs
    # pyenv shim magic is only for resolving to a versioned commands; it does not actually set up a virtualenv for LSPs that crave it
    # pyenv virtualenv-init -
    while set index (contains -i -- "/Users/jnguyen/.pyenv/plugins/pyenv-virtualenv/shims" $PATH)
        set -eg PATH[$index]
    end
    set -gx PATH '/Users/jnguyen/.pyenv/plugins/pyenv-virtualenv/shims' $PATH

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

    function _pyenv_virtualenv_hook --on-event fish_prompt

        set -l ret $status
        if [ -n "$VIRTUAL_ENV" ]
            pyenv activate --quiet; or pyenv deactivate --quiet; or true
        else
            pyenv activate --quiet; or true
        end
        return $ret
    end
end

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
    poetry sync --project $XDG_CONFIG_HOME/venv-update/ | ts >>$logfile &

    # Set pyenv PATH through fish_user_paths, which has higher precedence than raw PATH
    fish_add_path (pyenv root)/shims

    set pyenv_virtualenv_plugin (pyenv root)/plugins/pyenv-virtualenv
    test -d $pyenv_virtualenv_plugin; or git clone https://github.com/pyenv/pyenv-virtualenv.git $pyenv_virtualenv_plugin

    pyenv-init
end

status --is-login; and install
status --is-interactive; and main
