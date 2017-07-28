if status --is-login; and status --is-interactive
    set ssh_env_file $HOME/.ssh/ssh-agent-env

    function start_agent
        ssh-agent -c | sed 's/^echo/#/' > $ssh_env_file
        chmod 600 $ssh_env_file
        source $ssh_env_file
        ssh-add
    end

    function test_agent
        if ssh-add -l | grep -q 'The agent has no identities'
            ssh-add
            if test $status -eq 2
                start_agent
            end
        end
    end
        # start_agent
    if test -f $ssh_env_file
        source $ssh_env_file
    end

    if set -q SSH_AGENT_PID; and ps -ef | grep $SSH_AGENT_PID | grep -q 'ssh-agent'
        test_agent
    else
        echo start agent
        start_agent
    end
end
