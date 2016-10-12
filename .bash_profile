if [ -f  ~/.bashrc ]; then
    cd ~ && git pull
    . ~/.bashrc
fi

. ~/bin/bash_completion.sh
