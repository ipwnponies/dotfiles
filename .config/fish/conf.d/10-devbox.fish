function main
    if status --is-login
        # Sync dependencies
        devbox global install
    end

    if status --is-interactive

        # Add devbox to PATH
        devbox global shellenv | source

        # Vendor completions
        set completion $XDG_CONFIG_HOME/fish/completions/devbox.fish

        # Statically compile completion, with TTL
        set ttl (math '60*60*24*7') # 1 week
        function calc_age
            set file_age (stat -c %Y $argv[1])
            set current_time (date +%s)
            math $current_time - $file_age
        end

        if test ! -f $completion -o (calc_age $completion) -gt $ttl
            echo 'Regenerating devbox completion'
            devbox completion fish > $completion
        end

        set --append fish_complete_path $DEVBOX_PACKAGES_DIR/share/fish/vendor_completions.d
    end

end

time main
