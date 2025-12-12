set -x CARGO_INSTALL_ROOT $XDG_DATA_HOME/cargo
set -x CARGO_TARGET_DIR $XDG_CACHE_HOME/cargo
fish_add_path $CARGO_INSTALL_ROOT/bin --append

function main
    set crates (cat $XDG_CONFIG_HOME/cargo/tools.txt)
    for i in $crates
        cargo install --quiet --locked $i
    end
end

status --is-login; and main
