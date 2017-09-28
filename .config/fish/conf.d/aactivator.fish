function _activate_venv --on-variable PWD --description 'Automatically activate venv upon changing directory'
    set -l path $PWD
    set -l possible_venvs '/.activate.fish' '/virtualenv_run/bin/activate.fish' '/venv/bin/activate.fish'

    # Searches for aactivator bottom up
    while test $path != '/'
        for i in $path$possible_venvs
            # Iterate through possible known venv directories
            if test -e $i
                set activate_script $i
                break
            end
        end

        # If venv found, exit loop, else go up a directory and continue
        if set -q activate_script
            break
        else
            set path (dirname $path)
        end
    end

    if set -q activate_script
        if set -q ACTIVATED_VENV; and test $activate_script != $ACTIVATED_VENV;
            deactivate
        end

        set -g ACTIVATED_VENV $activate_script
        source $activate_script
    else if set -q ACTIVATED_VENV
        # No aactivator found, deactivate current venv
        deactivate
        set -e ACTIVATED_VENV
    end
end
