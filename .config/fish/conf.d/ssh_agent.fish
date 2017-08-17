if status --is-login; and status --is-interactive
    set ssh_env_file $HOME/.ssh/ssh-agent-env

    function start_agent
        ssh-agent -c | sed 's/^echo/#/' > $ssh_env_file
        chmod 600 $ssh_env_file
        source $ssh_env_file
    end

    function startup
        # Key is already loaded, nothing more to do
        if ssh-add -l ^&1 >/dev/null
            return
        end

        # Try loading existing existing agent
        if test -f $ssh_env_file
            source $ssh_env_file
        end

        # Test if existing agent has not gone stale
        ssh-add -l ^&1 >/dev/null
        if test $status -eq 1;
            # No keys loaded in ssh-agent
            ssh-add
        else if test $status -eq 2;
            # No ssh-agent running
            start_agent
            ssh-add
        end
    end

    startup
end
