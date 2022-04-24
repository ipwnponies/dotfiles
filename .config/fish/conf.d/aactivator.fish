function _activate_venv --on-variable PWD --description 'Automatically activate venv upon changing directory'
    set -l path $PWD
    set -l found 0

    # Searches for aactivator bottom up
    while test $path != '/'; and test $found -eq 0
        set activate_script "$path/activate.fish"

        # If venv found, exit loop, else go up a directory and continue
        if test -e $activate_script
            set found 1
            _aactivator_actually_activate $activate_script
        end

        # Up a dir level
        set path (dirname $path)
    end

    # No aactivator found, deactivate current venv
    if set -q ACTIVATED_VENV; and test $found -eq 0
        deactivate
        set -e ACTIVATED_VENV
    end
end

function _aactivator_actually_activate
    set script $argv[1]
    if set -q ACTIVATED_VENV; and test $script != $ACTIVATED_VENV;
        deactivate
    end

    set -g ACTIVATED_VENV $script
    source $script
end
