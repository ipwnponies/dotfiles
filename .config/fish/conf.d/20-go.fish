set -gx GOPATH $XDG_DATA_HOME/go
fish_add_path --global $GOPATH/bin

set -gx AQUA_GLOBAL_CONFIG $XDG_CONFIG_HOME/aqua/aqua.yaml

function install_aqua --description 'Install aqua if not present'
    go install github.com/aquaproj/aqua/v2/cmd/aqua@latest
end

type -q aqua; or install_aqua
status --is-login; and aqua install

fish_add_path (aqua root-dir)/bin
