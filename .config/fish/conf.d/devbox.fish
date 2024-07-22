# Vendor completions
devbox completion fish | source

# Add devbox to PATH
devbox global shellenv --init-hook | source

# Sync dependencies
status --is-login; and devbox global install
