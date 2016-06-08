# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac


# don't put duplicate lines in the history. See bash(1) for more options
HISTCONTROL="erasedups:ignorespace"
HISTIGNORE="up *"
# append to the history file, don't overwrite it
shopt -s histappend

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
shopt -s globstar

source ~/.shrc

# reconnect ssh-agent under tmux
if [[ $TMUX ]]; then
    PROMPT_COMMAND='eval export "$(tmux show-environment | grep \^SSH_AUTH_SOCK=)"'"; $PROMPT_COMMAND"
fi

# Use case-insensitive filename globbing
shopt -s nocaseglob

# WE NEED MOAR POWER!
shopt -s extglob
shopt -s nocaseglob
shopt -s histappend
shopt -s histreedit
shopt -s cdspell
. ~/.bash_function
export LS_COLORS='ow=01;37:';
# some useful aliases
alias ls='ls -CF --color=always'
alias ll='ls -lh'
alias la='ls -lhA'
alias df='df -h'
alias du='du -h'
alias j='jobs'
alias g='egrep -i --color=auto'

if shopt -q login_shell && [ -n "$SSH_CLIENT" ] && [ -z "$TMUX" ]; then
    tmux attach || tmux
fi
