if status --is-interactive
    if not pip list | grep powerline-status
        pip install --user powerline-status
    end
end
