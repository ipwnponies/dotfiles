# Generate bd completions only on login+interactive shells and only after TTL
# to avoid paying the regeneration cost on every new shell while still keeping
# completions fresh enough for user-facing changes.
function __bd_is_expired
    set -l file $argv[1]
    test -f $file; or return 0

    set -l ttl (math '60*60*24*7')
    set -l current_time (date +%s)
    set -l file_age (stat -c %Y $file 2>/dev/null; or stat -f %m $file 2>/dev/null; or echo 0)

    test (math $current_time - $file_age) -gt $ttl
end

function __bd_regenerate_completion
    set -l completion_path $XDG_CONFIG_HOME/fish/completions/bd.fish
    bd completion fish >$completion_path
end

if status --is-interactive; and status --is-login; and type -q bd
    set -l completion_path $XDG_CONFIG_HOME/fish/completions/bd.fish
    if __bd_is_expired $completion_path
        __bd_regenerate_completion
    end
end
