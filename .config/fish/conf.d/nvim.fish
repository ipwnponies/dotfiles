function main
    set -gx NVIM_AVANTE_ENABLED 0
    set -gx CODECOMPANION_CLAUDE_TOKEN

    set -l nvim_local (dirname (status --current-filename))/nvim_local.fish
    if test -e $nvim_local
        source $nvim_local
    end
end

status --is-interactive; and main
