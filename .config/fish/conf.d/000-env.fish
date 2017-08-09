# General environment variables

if status --is-login
    # XDG defaults
    set -x XDG_DATA_HOME $HOME/.local/share
    set -x XDG_CONFIG_HOME $HOME/.config
    set -x XDG_CACHE_HOME $HOME/.cache

    set PATH "$HOME/bin" $PATH

    if type -q nvim
        set -x EDITOR nvim
    else
        set -x EDITOR vim
    end

    # Show entire dir name for pwd
    set -x fish_prompt_pwd_dir_length 0

    if status --is-interactive
        bash -c 'source ~/.bash_profile' &

        if type -q tmux; and not set -q TMUX; and set -q SSH_CLIENT;
            # Automatically reattach to tmux session
            tmux attach
        end
    end
end
