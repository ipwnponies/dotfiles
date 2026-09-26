function main
    if test -d $OMF_PATH
        # Load Oh My Fish configuration.
        source $OMF_PATH/init.fish
    end

end

function install
    if test -d $OMF_PATH
        set bundle $XDG_CONFIG_HOME/omf/bundle

        # This can introduce issues wth newly installed packages They won't work correctly until the next shell
        # startup This is acceptable because it's infrequent and not worth paying on every shell startup.
        is_expired $bundle; and omf install
    else
        # This is used to undo clobbering by the omf installer
        set current_file (status --current-filename)

        $XDG_CONFIG_HOME/fish/plugins/oh-my-fish/bin/install --noninteractive --offline
        git -C (dirname $current_file) checkout -- $current_file

        omf reload
    end
end

set OMF_PATH $XDG_DATA_HOME/omf/

status --is-interactive; and main
status --is-login; and status --is-interactive; and install

# Helpers are global; erase them so they don't shadow commands (e.g. coreutils `install`) later
functions --erase main install
