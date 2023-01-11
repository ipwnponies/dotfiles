fish_add_path $HOME/.local/bin

if status --is-interactive
    if not type -q poetry
        echo 'poetry is not installed'
        exit
    end

    set completion_path (dirname (status filename))/../completions/poetry.fish

    if not test -e $completion_path
        echo 'Installing poetry completions'
        poetry completions > $completion_path
    end
end
