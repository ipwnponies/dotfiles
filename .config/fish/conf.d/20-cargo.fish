set -x CARGO_INSTALL_ROOT $XDG_DATA_HOME/cargo
set -x CARGO_TARGET_DIR $XDG_CACHE_HOME/cargo
fish_add_path $CARGO_INSTALL_ROOT/bin --append

function main
    not type --query _pay-respects-module-100-runtime-rules; and cargo install pay-respects-module-runtime-rules
    cargo install --locked tree-sitter-cli
end

status --is-login; and main
