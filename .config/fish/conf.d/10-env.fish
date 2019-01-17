# General environment variables

if status --is-login
    # XDG defaults
    set -x XDG_DATA_HOME $HOME/.local/share
    set -x XDG_CONFIG_HOME $HOME/.config
    set -x XDG_CACHE_HOME $HOME/.cache

    set PATH "$HOME/bin" $PATH

    # Set less arguments so they will be applied when used as pager
    set -x LESS '-XFR -i -M -w -z-4'

    if type -q nvim
        set -x EDITOR nvim
    else
        set -x EDITOR vim
    end

    # Show entire dir name for pwd
    set -x fish_prompt_pwd_dir_length 0

    if status --is-interactive
        if test -d ~/.git
            git pull
            git submodule update --init
        end

        # Deprecation warning
        if test -e ~/.bashrc_local
            set_color --bold red
            printf 'Executing .bashrc_local is deprecated for fish, please port this to %s if necessary.\n' (status current-filename)
            set_color normal
        end
    end
end