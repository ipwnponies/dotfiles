if status --is-login; and status --is-interactive; and type -q go
    set -gx GOPATH $XDG_DATA_HOME/go
    set PATH $PATH $GOPATH/bin

    type -q jiq; or begin; echo 'Installing jiq...'; and go get github.com/fiatjaf/jiq/cmd/jiq; end
    type -q fac; or begin; echo 'Installing fac...'; and go get github.com/mkchoi212/fac; end
    type -q gron; or begin; echo 'Installing gron...'; and go get github.com/tomnomnom/gron; end
    type -q dive; or begin; echo 'Installing dive...'; and go get github.com/wagoodman/dive; end
end
