function _activate_venv --on-variable PWD --description 'Automatically activate venv upon changing directory'
    set -l path $PWD

    # Searches for aactivator bottom up
    while test $path != '/'
        if test -e $path/.activate.fish
            set activate_script_dir $path
            break
        else
            set path (dirname $path)
        end
    end

    if set -q activate_script_dir
        if set -q ACTIVATED_VENV; and test $activate_script_dir != $ACTIVATED_VENV;
            deactivate
        end

        set -g ACTIVATED_VENV $activate_script_dir
        source $activate_script_dir/.activate.fish
    else if set -q ACTIVATED_VENV
        # No aactivator found, deactivate current venv
        deactivate
        set -e ACTIVATED_VENV
    end
end
