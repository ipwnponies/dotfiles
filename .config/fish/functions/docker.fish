# Wrapper to docker
#
# Send SIGWINCH to docker exec process so that initial tty size is correctly set.
function docker
    if test $argv[1] = 'exec'; and contains -- '-it' $argv
        command docker $argv &
        set pid %last
        fish -c "sleep 0.1; kill -SIGWINCH $pid" &
        fg $pid
    else
        command docker $argv
    end
end

