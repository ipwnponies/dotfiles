function main
    # Add devbox to PATH
    devbox global shellenv --init-hook | source

    if status --is-login
        # Sync dependencies
        status --is-login; and devbox global install
    end

    if status --is-interactive
        # Vendor completions
        devbox completion fish | source
        set --append fish_complete_path $DEVBOX_PACKAGES_DIR/share/fish/vendor_completions.d
    end

end

main
