set -gx GOPATH $XDG_DATA_HOME/go
fish_add_path --global $GOPATH/bin

if status --is-login; and status --is-interactive; and type -q go
    type -q fac; or go get github.com/mkchoi212/fac
end
