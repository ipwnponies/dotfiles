if status --is-interactive
    set venv "$XDG_CONFIG_HOME/virtualenv"
    if not test -d $venv
        virtualenv --python python3 $venv
    end

    set PATH "$XDG_CONFIG_HOME/virtualenv/bin" $PATH

    set packages 'mycli' 'powerline-status'
    for i in $packages
        if not eval $venv/bin/pip show -q $i
            eval $venv/bin/pip install $i
        end
    end
end
