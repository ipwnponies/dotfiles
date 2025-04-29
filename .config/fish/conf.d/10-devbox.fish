function main

    function is_expired
        set file $argv[1]
        test -f $file; or return 0

        # Expire dynamic generations after a week
        set ttl (math '60*60*24*7') # 1 week

        set current_time (date +%s)
        set file_age (stat -c %Y $file; or echo 0)

        test (math $current_time - $file_age) -gt $ttl
    end

    # This config only sets env vars and should be sourced first
    # This allows later configs to update stale values
    set generated_config $XDG_CONFIG_HOME/fish/conf.d/00-devbox-generated_local.fish

    if is_expired $generated_config
        echo 'Regenerating devbox config'
        # Pre-generates env vars that adds devbox to PATH
        devbox global shellenv > $generated_config
        exec fish
    end

    # Vendor completions
    set -l generated_completion $XDG_CONFIG_HOME/fish/completions/devbox.fish


    if is_expired $generated_completion
        echo 'Regenerating devbox completion'
        devbox completion fish > $generated_completion
    end

    set --append fish_complete_path $DEVBOX_PACKAGES_DIR/share/fish/vendor_completions.d
end

function install
    # Sync dependencies
    devbox global install
end

status --is-login; and install
status --is-interactive; and main
