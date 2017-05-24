# XDG defaults
set -x XDG_DATA_HOME $HOME/.local/share
set -x XDG_CONFIG_HOME $HOME/.config
set -x XDG_CACHE_HOME $HOME/.cache

set PATH "$HOME/bin" $PATH
set -x EDITOR vim

# Show entire dir name for pwd
set -x fish_prompt_pwd_dir_length 0

if test -f config_local.fish
    source config_local.fish
end

if status --is-login
    bash -c 'source ~/.bash_profile'

    if not set -q TMUX; and set -q SSH_CLIENT; and type -q tmux
        tmux attach
    end
end
