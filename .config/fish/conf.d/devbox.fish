# Vendor completions
devbox completion fish | source

# Sync dependencies
status --is-login; and devbox --config $XDG_CONFIG_HOME/devbox/devbox.json install

# Add devbox to PATH
devbox --config $XDG_CONFIG_HOME/devbox/devbox.json shellenv | source
