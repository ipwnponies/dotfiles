cd ~
if [ ! -d .git ]; then
    git clone --no-checkout git@git.yelpcorp.com:devs/jngu/dotfiles tmp-dotfiles
    mv tmp-dotfiles/.git .
    rmdir tmp-dotfiles
    git checkout  -f
else
    git pull
fi
git submodule update --init
