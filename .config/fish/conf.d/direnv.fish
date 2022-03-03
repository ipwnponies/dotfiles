if not type -q direnv
    status --is-interactive; and echo 'direnv  is not installed: https://direnv.net/'
    exit
else
    direnv hook fish | source
end
