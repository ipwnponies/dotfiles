function main
    if not type -q direnv
        echo 'direnv is not installed: https://direnv.net/'
        return
    else
        direnv hook fish | source
    end
end

status --is-interactive; and main

# Helpers are global; erase them so they don't shadow commands (e.g. coreutils `install`) later
functions --erase main
