function fish_user_key_bindings
    # Override plugin-expand. Its expand:choose-next function has weird behaviour
    bind -M expand \t complete

    fzf_key_bindings
end
