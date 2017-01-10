cd ~
if [ -d ~/.git ]; then
    git pull
    git submodule update --init
fi

if [ -f  ~/.shrc ]; then
    . ~/.shrc
fi

########################################
# Interactive shell only below this line
########################################
[ -z "$PS1" ] && return

if [ -f  ~/.bashrc ]; then
    . ~/.bashrc
fi

# Reattach to tmux session if one exists
if shopt -q login_shell && [ -n "$SSH_CLIENT" ] && [ -z "$TMUX" ]; then
    tmux attach
else
    echo 'No running tmux session'
fi

if type aactivator &>/dev/null ; then
    eval "$(aactivator init)"
else
    echo 'aactivator does not exist on this system'
fi

export PS1_GREEN=$(tput setaf 2)$(tput bold)
export PS1_BLUE=$(tput setaf 4)$(tput bold)
export PS1_RED=$(tput setaf 1)$(tput bold)
export PS1_YELLOW=$(tput setaf 3)$(tput bold)
export PS1_CYAN=$(tput setaf 6)$(tput bold)
export PS1_DEFAULT=$(tput sgr0)
export PS1='[\D{%Y-%m-%d} \t] \[$PS1_BLUE\]\u\[$PS1_DEFAULT\]@\[$PS1_GREEN\]\h\[$PS1_DEFAULT\]:\[$PS1_YELLOW\]\w\[$PS1_DEFAULT\]\[$PS1_CYAN\]$(__git_ps1)\[$PS1_RED\]${?##0}\[$PS1_DEFAULT\]\$ \[$PS1_DEFAULT\]'

# don't put duplicate lines in the history. See bash(1) for more options
export HISTCONTROL="erasedups:ignorespace"
export HISTIGNORE="up *"

export LS_COLORS='ow=01;37:';
