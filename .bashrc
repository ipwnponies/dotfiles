########################################
# Interactive shell only below this line
########################################
[ -z "$PS1" ] && return

# append to the history file, don't overwrite it
shopt -s histappend

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
shopt -s globstar

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

# some useful aliases
alias ls='ls -F --color=always'
alias ll='ls -lh'
alias la='ls -lhA'
alias df='df -h'
alias du='du -h --max-depth=1'
alias j='jobs -l'
alias g='grep -Pi --color=auto'
alias ps='ps -f'

if [ -f ~/bin/bash_completion.sh ]; then
    . ~/bin/bash_completion.sh
else
    echo 'No bash completion available'
fi

if [ -f ~/.bash_function ]; then
    . ~/.bash_function
fi

# Directories available at top level for cd
CDPATH=.:~/cdpath

# Keep tmux ssh-agent information updated
if [[ $TMUX ]]; then
    # This should be exported but somebody put a command into $PROMPT_COMMAND that is only
    # available in .profile and only available to login shell...
    PROMPT_COMMAND='eval export "$(tmux show-environment | grep \^SSH_AUTH_SOCK=)"'"; $PROMPT_COMMAND"
fi
