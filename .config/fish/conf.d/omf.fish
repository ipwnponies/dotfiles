if status --is-interactive;
    set -l omf_conf $XDG_DATA_HOME/omf/

    if test -d $omf_conf
        # Configure oh-my-fish

        set -q XDG_DATA_HOME;
            and set -gx OMF_PATH "$XDG_DATA_HOME/omf";
            or set -gx OMF_PATH "$HOME/.local/share/omf";

        # Load Oh My Fish configuration.
        source $OMF_PATH/init.fish

        # Install all omf plugins upon login
        if status --is-login
            omf install
        end

    else if status --is-login
        # Install oh-my-fish asynchronously. This is better for quicker user experience but also means we
        # need shell restart before environment configuration converges.  This needs to run after the omf
        # configuration since it is asyncrhonous and will get into race condition.

        # This is used to undo clobbering by the omf installer
        set -l current_file (status --current-filename)

        set install_script "
            echo 'Installing oh-my-fish in background...'
            $XDG_CONFIG_HOME/fish/plugins/oh-my-fish/bin/install --noninteractive --offline
            git checkout $current_file
            echo 'Finished installing, reload shell if you want omf'
        "
        fish -c $install_script &
    end

end
