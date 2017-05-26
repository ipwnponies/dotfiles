set -l omf_conf $XDG_DATA_HOME/omf/

# Configure oh-my-fish
if status --is-interactive; and test -e $omf_conf
    # Path to Oh My Fish install.
    set -q XDG_DATA_HOME
      and set -gx OMF_PATH "$XDG_DATA_HOME/omf"
      or set -gx OMF_PATH "$HOME/.local/share/omf"

    # Configure path to z (autojump)
    set -x Z_SCRIPT_PATH $XDG_CONFIG_HOME/z/z/z.sh

    # Load Oh My Fish configuration.
    source $OMF_PATH/init.fish

    # Install omf plugins upon login
    if status --is-login
        omf install
    end
end

# Install oh-my-fish asynchronously. This is better for quicker user experience but also means we
# need shell restart before environment configuration converges.  This needs to run after the omf
# configuration since it is asyncrhonous and will get into race condition.
if status --is-login; and status --is-interactive; and not test -e $omf_conf
    echo 'Installing oh-my-fish in background...'

    # This is used to undo clobbering by the omf installer
    set -l current_file (status --current-filename)

    set install_script "
        $XDG_CONFIG_HOME/fish/plugins/oh-my-fish/bin/install --noninteractive --offline
        git checkout $current_file
        echo 'Finished installing, reload shell if you want omf'
    "
    fish -c $install_script &
end
