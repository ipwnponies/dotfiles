function main
    if test -d $OMF_PATH
        # Load Oh My Fish configuration.
        source $OMF_PATH/init.fish
    end

end

function install
    function is_expired
        set file $argv[1]
        test -f $file; or return 0
        # Expire dynamic generations after a week
        set ttl (math '60*60*24*7') # 1 week

        set file_age (stat -c %Y $file)
        set current_time (date +%s)

        test (math $current_time - $file_age) -gt $ttl
    end

    if test -d $OMF_PATH
        set bundle $XDG_CONFIG_HOME/omf/bundle

        # This can introduce issues wth newly installed packages They won't work correctly until the next shell
        # startup This is acceptable because it's infrequent and not worth paying on every shell startup.

        set logfile $XDG_CACHE_HOME/omf/log
        is_expired $bundle; and omf install
    else
        # This is used to undo clobbering by the omf installer
        set current_file (status --current-filename)

        $XDG_CONFIG_HOME/fish/plugins/oh-my-fish/bin/install --noninteractive --offline
        git checkout $current_file

        omf reload
    end
end

set OMF_PATH $XDG_DATA_HOME/omf/

status --is-interactive; and main
status --is-login; and status --is-interactive; and install
