# Generate bd completions only on login+interactive shells and only after TTL
# to avoid paying the regeneration cost on every new shell while still keeping
# completions fresh enough for user-facing changes.
function __bd_regenerate_completion
    set -l completion_path $XDG_CONFIG_HOME/fish/completions/bd.fish
    bd completion fish >$completion_path
end

if status --is-interactive; and status --is-login; and type -q bd
    set -l completion_path $XDG_CONFIG_HOME/fish/completions/bd.fish
    if is_expired $completion_path
        __bd_regenerate_completion
    end
end
