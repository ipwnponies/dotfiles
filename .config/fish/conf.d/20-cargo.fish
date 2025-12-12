set -x CARGO_INSTALL_ROOT $XDG_DATA_HOME/cargo
set -x CARGO_TARGET_DIR $XDG_CACHE_HOME/cargo
fish_add_path $CARGO_INSTALL_ROOT/bin --append

function main
    set crates pay-respects-module-runtime-rules@0.1.9 tree-sitter-cli@0.26.2
    for i in $crates
        cargo install --quiet --locked $i
    end
end

status --is-login; and main
