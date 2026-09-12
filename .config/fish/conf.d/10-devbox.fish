function main
    set --append fish_complete_path $DEVBOX_PACKAGES_DIR/share/fish/vendor_completions.d

    set -l local_pkgs $XDG_DATA_HOME/devbox_local/.devbox/nix/profile/default
    fish_add_path $local_pkgs/bin
    set --append fish_complete_path $local_pkgs/share/fish/vendor_completions.d
    set --prepend MANPATH $local_pkgs/share/man
end

function install
    # Sync dependencies, unless recently synced and configs haven't changed
    set -l stamp $XDG_STATE_HOME/devbox/install.stamp
    is_expired $stamp \
        $XDG_CONFIG_HOME/devbox/devbox.json $XDG_CONFIG_HOME/devbox/devbox.lock \
        $XDG_DATA_HOME/devbox_local/devbox.json $XDG_DATA_HOME/devbox_local/devbox.lock
    or return

    mkdir -p $XDG_STATE_HOME/devbox
    set -l log $XDG_STATE_HOME/devbox/install.log
    fish --no-config -c "
        devbox global install >>$log 2>&1
        test -f $XDG_DATA_HOME/devbox_local/devbox.json; and devbox install --config $XDG_DATA_HOME/devbox_local >>$log 2>&1
        touch $stamp
    " &
end

function regenerate --description 'Refresh devbox generated files, if expired'
    # This config only sets env vars and should be sourced first
    # This allows later configs to update stale values
    set generated_config $XDG_CONFIG_HOME/fish/conf.d/00-devbox-generated_local.fish

    if is_expired $generated_config
        echo 'Regenerating devbox config'
        # Pre-generates env vars that adds devbox to PATH
        devbox global shellenv | grep -e '^export PATH=' -e '^export DEVBOX_' >$generated_config
        exec fish
    end

    # Vendor completions
    set -l generated_completion $XDG_CONFIG_HOME/fish/completions/devbox.fish

    if is_expired $generated_completion
        echo 'Regenerating devbox completion'
        devbox completion fish >$generated_completion
    end
end

status --is-login; and install
status --is-interactive; and main
status --is-interactive; and status is-login; and regenerate
