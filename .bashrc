# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac


# don't put duplicate lines in the history. See bash(1) for more options
HISTCONTROL=erasedups
# append to the history file, don't overwrite it
shopt -s histappend

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
shopt -s globstar

source ~/.shrc

# reconnect ssh-agent under tmux
if [[ $TMUX ]]; then
    PROMPT_COMMAND='eval export "$(tmux show-environment | grep \^SSH_AUTH_SOCK=)"'
fi
