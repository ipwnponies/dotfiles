if status --is-interactive;
    set -l omf_conf $XDG_DATA_HOME/omf/

    if test -d $omf_conf
        # Configure oh-my-fish

        set -gx OMF_PATH "$XDG_DATA_HOME/omf";

        # Load Oh My Fish configuration.
        source $OMF_PATH/init.fish

        # Install all omf plugins upon login
        if status --is-login
            # This can introduce issues wth newly installed packages They won't work correctly until the next shell
            # startup This is acceptable because it's infrequent and not worth paying on every shell startup.
            omf install &
        end

    else if status --is-login
        # This is used to undo clobbering by the omf installer
        set -l current_file (status --current-filename)

        eval $XDG_CONFIG_HOME/fish/plugins/oh-my-fish/bin/install --noninteractive --offline
        git checkout $current_file

        # Exec into a new fish shell so omf settings can load correctly
        exec fish --login
    end

end
