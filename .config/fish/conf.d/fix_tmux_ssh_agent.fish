function fix_tmux_ssh_agent --description 'Keep tmux ssh-agent information up-to-date' --on-event fish_preexec
    if set -q TMUX; and set -l ssh_env (tmux show-environment | grep \^SSH_AUTH_SOCK=)
        eval export "$ssh_env"
    end
end
