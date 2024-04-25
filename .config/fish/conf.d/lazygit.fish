if status --is-interactive; and type -q lazygit
    set --local lazygit_dir "$XDG_CONFIG_HOME/lazygit"
    set --export LG_CONFIG_FILE "$lazygit_dir/config.yml,$lazygit_dir/config_local.yaml"
end
