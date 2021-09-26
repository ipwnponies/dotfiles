# Load ssh keys
if status --is-interactive
    if test (uname -o) = 'Darwin'
        # macos ssh can use OS keychain, no need for ssh-agent
        exit
    end

    if not type -q keychain
        echo 'Install keychain to manage ssh-agent'
        exit
    end

    keychain --eval --quiet --quick | source
end
