set -x CARGO_INSTALL_ROOT $XDG_DATA_HOME/cargo
set -x CARGO_TARGET_DIR $XDG_CACHE_HOME/cargo
fish_add_path $CARGO_INSTALL_ROOT/bin --append

function main
    type -q cargo; or exit

    set -l stamp $XDG_STATE_HOME/cargo/install.stamp
    is_expired $stamp $XDG_CONFIG_HOME/cargo/tools.txt; or return
    mkdir -p (dirname $stamp)

    set logfile "$XDG_CACHE_HOME/cargo-install.log"
    fish --no-config -c "
        mkdir -p (dirname $logfile)
        set failed 0
        for i in (cat $XDG_CONFIG_HOME/cargo/tools.txt)
            if not cargo install --quiet --locked \$i >>$logfile 2>&1
                echo \"Failed to install \$i. Check $logfile\"
                set failed 1
            end
        end
        test \$failed -eq 0; and touch $stamp
    " &
end

status --is-login; and main
