function main
    if not type -q direnv
        echo 'direnv  is not installed: https://direnv.net/'
        exit
    else
        direnv hook fish | source
    end
end

status --is-interactive; and main
