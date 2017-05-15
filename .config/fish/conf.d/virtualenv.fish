if status --is-interactive
    set venv "$HOME/.local/virtualenv"
    if not test -d $venv
        virtualenv --python python3 $venv
    end

    set packages 'mycli' 'powerline-status'
    for i in $packages
        if not eval $venv/bin/pip list | tail -n +1 | grep --silent $i
            eval $venv/bin/pip install $i
        end
    end
end
