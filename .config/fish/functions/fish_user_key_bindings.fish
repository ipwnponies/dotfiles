function fish_user_key_bindings
    # Disable plugin-expand binding override, remap binding to something else
    bind --erase --sets-mode expand \t
    bind --sets-mode expand \cx expand:execute
end
