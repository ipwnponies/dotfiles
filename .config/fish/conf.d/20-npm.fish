# Installation of local npm library and bun globals

function install
    type -q npm; or return

    set venv $argv[1]

    set -l stamp $XDG_STATE_HOME/npm/install.stamp
    is_expired $stamp $venv/package.json $venv/package-lock.json; or return
    mkdir -p (dirname $stamp)

    set logfile "$XDG_CACHE_HOME/npm"
    fish --no-config -c "
        mkdir -p (dirname $logfile)
        if npm ci --lockfile-version 3 --loglevel=error --prefix $venv >> $logfile 2>&1
            touch $stamp
        else
            echo 'Uh... that didn\'t work gud. So check out $logfile'
        end
    " &
end

function install_bun_globals
    type -q bun; or return

    set bun_manifest "$XDG_CONFIG_HOME/npm/package.bun.json"
    set logfile "$XDG_CACHE_HOME/bun/log.txt"

    if not test -f $bun_manifest
        return
    end

    set -l stamp $XDG_STATE_HOME/bun/install.stamp
    is_expired $stamp $bun_manifest; or return
    mkdir -p (dirname $stamp)

    fish --no-config -c "
        mkdir -p (dirname $logfile)
        set failed 0
        set packages (jq -r '.dependencies | keys[]' $bun_manifest 2>/dev/null)
        if test -n \"\$packages\"
            for pkg in \$packages
                if not bun install -g \$pkg >> $logfile 2>&1
                    echo \"Failed to install \$pkg. Check $logfile\"
                    set failed 1
                end
            end
        end
        test \$failed -eq 0; and touch $stamp
    " &
end

function main
    set venv "$XDG_CONFIG_HOME/npm"
    fish_add_path --global $venv/node_modules/.bin
    # bun global installs
    fish_add_path "$XDG_CACHE_HOME/.bun/bin"

    if status --is-login
        install $venv
        install_bun_globals
    end
end

main
