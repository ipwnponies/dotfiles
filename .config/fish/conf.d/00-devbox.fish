# Vendor completions
devbox completion fish | source

# Add devbox to PATH
devbox global shellenv --init-hook | source

# Sync dependencies
status --is-login; and devbox global install

set --append fish_complete_path $DEVBOX_PACKAGES_DIR/share/fish/vendor_completions.d
