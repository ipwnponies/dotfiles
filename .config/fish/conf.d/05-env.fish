# General environment variables

# XDG defaults
set -x XDG_DATA_HOME $HOME/.local/share
set -x XDG_CONFIG_HOME $HOME/.config
set -x XDG_CACHE_HOME $HOME/.cache
set -x XDG_STATE_HOME $HOME/.local/state

fish_add_path --global $HOME/.local/bin
fish_add_path --prepend --move --global $HOME/bin

set -x RIPGREP_CONFIG_PATH "$XDG_CONFIG_HOME/ripgrep/rc"
set -x PYTHONSTARTUP $XDG_CONFIG_HOME/python/pythonrc.py
set -x INPUTRC $XDG_CONFIG_HOME/readline/inputrc
set -x EDITOR nvim

if status --is-interactive

    # Set less arguments so they will be applied when used as pager
    set -x LESS '--no-init --RAW-CONTROL-CHARS --ignore-case --LONG-PROMPT --hilite-unread --window=-4'

    # Show entire dir name for pwd
    set -x fish_prompt_pwd_dir_length 0

    if status --is-login
        if test -d ~/.git
            fish --no-config -c '
                cd $HOME
                git fetch

                # If no updates, avoid further git operations
                if test (git rev-list --count \'..@{u}\') -eq 0
                    exit
                end

                git pull
                git submodule update --init
            ' &
        end

        # Deprecation warning
        if test -e ~/.bashrc_local
            set_color --bold red
            printf 'Executing .bashrc_local is deprecated for fish, please port this to %s if necessary.\n' (status current-filename)
            set_color normal
        end
    end

    if set -q --universal fish_user_paths
        set_color --bold yellow
        printf 'Universal fish_user_paths is still set; the one-time PATH cleanup has not been run on this machine.\n'
        set_color normal
        printf 'Inspect with `set --show fish_user_paths`, then run `set --erase --universal fish_user_paths`.\n'
    end

    # This allows using python breakpoint() to invoke debugger
    set -x PYTHONBREAKPOINT pudb.set_trace
end
