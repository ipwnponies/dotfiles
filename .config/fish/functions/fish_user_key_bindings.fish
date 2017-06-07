function fish_user_key_bindings
    bind \cx edit_command_buffer

    # Override plugin-expand. Its expand:choose-next function has weird behaviour
    bind -M expand \t complete

    fzf_key_bindings
end
