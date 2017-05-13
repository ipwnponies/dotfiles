set -x PATH "$HOME/bin" "$HOME/.local/bin" $PATH
set -x EDITOR vim

# Show entire dir name for pwd
set -x fish_prompt_pwd_dir_length 0

if test -f config_local.fish
    source config_local.fish
end

if status --is-login; and test -z $TMUX; and test -n $SSH_CLIENT
    tmux attach
end
