set -gx GOPATH $XDG_DATA_HOME/go
fish_add_path --global $GOPATH/bin

set -gx AQUA_GLOBAL_CONFIG $XDG_CONFIG_HOME/aqua/aqua.yaml

function install_aqua --description 'Install aqua if not present'
    go install github.com/aquaproj/aqua/v2/cmd/aqua@latest
end

function install_aqua_tools --description 'Sync aqua-managed tools, unless recently synced and config unchanged'
    set -l stamp $XDG_STATE_HOME/aqua/install.stamp
    is_expired $stamp $AQUA_GLOBAL_CONFIG; or return

    mkdir -p (dirname $stamp)
    fish --no-config -c "aqua install -a; and touch $stamp" &
end

if type -q go
    if status --is-login
        type -q aqua; or install_aqua
        install_aqua_tools
    end

    # aqua root-dir is always $XDG_DATA_HOME/aquaproj-aqua; skip shelling out for it
    fish_add_path --global $XDG_DATA_HOME/aquaproj-aqua/bin
end

# Helpers are global; erase them so they don't shadow commands (e.g. coreutils `install`) later
functions --erase install_aqua install_aqua_tools
