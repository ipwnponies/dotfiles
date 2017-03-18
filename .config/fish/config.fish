set -x PATH ~/bin ~/.local/bin $PATH
set -x EDITOR vim
set -x __Z_DATA ~/.config/fish/z_data

# Show entire dir name for pwd
set -x fish_prompt_pwd_dir_length 0

if test -f config_local.fish
    source config_local.fish
end
