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
shopt -s checkjobs
shopt -s checkwinsize
shopt -s extglob
shopt -s nocaseglob
shopt -s histappend
shopt -s histreedit
shopt -s histverify
shopt -s cdspell
. ~/.bash_function
export LS_COLORS='ow=01;37:';
# some useful aliases
alias ls='ls -F --color=always'
alias ll='ls -lh'
alias la='ls -lhA'
alias df='df -h'
alias du='du -h --max-depth=1'
alias j='jobs -l'
alias g='egrep -i --color=auto'

# Reattach to tmux session if one exists
if shopt -q login_shell && [ -n "$SSH_CLIENT" ] && [ -z "$TMUX" ]; then
    tmux attach
else
    echo 'No running tmux session'
fi

CDPATH=.:~/cdpath

PS1_GREEN=$(tput setaf 2)$(tput bold)
PS1_BLUE=$(tput setaf 4)$(tput bold)
PS1_YELLOW=$(tput setaf 3)$(tput bold)
PS1_CYAN=$(tput setaf 6)$(tput bold)
PS1_DEFAULT=$(tput sgr0)
PS1='\[$PS1_BLUE\]\u\[$PS1_DEFAULT\]@\[$PS1_GREEN\]\h\[$PS1_DEFAULT\]:\[$PS1_YELLOW\]\w\[$PS1_DEFAULT\]\[$PS1_CYAN\]$(__git_ps1)\[$PS1_DEFAULT\]\$ \[$PS1_DEFAULT\]'

if type aactivator &>/dev/null ; then
    eval "$(aactivator init)"
else
    echo 'aactivator does not exist on this system'
fi
