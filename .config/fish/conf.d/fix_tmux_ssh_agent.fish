function fix_tmux_ssh_agent --description 'Keep tmux ssh-agent information up-to-date' --on-event fish_preexec
    if set -q TMUX
        eval export "(tmux show-environment | grep \^SSH_AUTH_SOCK=)"
    end
end
