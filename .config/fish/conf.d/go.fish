if status --is-login; and status --is-interactive; and type -q go
    set -gx GOPATH $XDG_DATA_HOME/go
    set PATH $PATH $GOPATH/bin

    go get github.com/fiatjaf/jiq/cmd/jiq
    go get github.com/mkchoi212/fac
    go get github.com/tomnomnom/gron
end
