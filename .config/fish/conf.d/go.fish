if status --is-login; and status --is-interactive; and type -q go
    set -gx GOPATH $XDG_DATA_HOME/go
    set PATH $PATH $GOPATH/bin

    type -q jiq; or go get github.com/fiatjaf/jiq/cmd/jiq
    type -q fac; or go get github.com/mkchoi212/fac
    type -q gron; or go get github.com/tomnomnom/gron
end
