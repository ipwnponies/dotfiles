if status --is-interactive; and type -q lazygit
    set --local lazygit_dir "$XDG_CONFIG_HOME/lazygit"
    set --local default $lazygit_dir/config.yml
    set --local custom $lazygit_dir/config_local.yaml

    if test -O $custom
        set --export LG_CONFIG_FILE $default,$custom
    end
end
