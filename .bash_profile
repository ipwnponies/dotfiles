if [ -f  ~/.bashrc ]; then
    cd ~ && git pull
    . ~/.bashrc
fi

if [ -f ~/bin/bash_completion.sh ]; then
    . ~/bin/bash_completion.sh
else
    echo 'No bash completion available'
fi
