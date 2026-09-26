set --export NAVI_CONFIG $XDG_CONFIG_HOME/navi/config.yaml


# This is trimmed down custom `navi widget fish`
function _navi_smart_replace
    set -l current_process (commandline -p | string trim)

    # Leave the commandline untouched if navi is cancelled
    set -l selection (navi --print --query "$current_process" | string collect)
    test -n "$selection"; and commandline -- $selection
    commandline -f repaint
end

bind \cg _navi_smart_replace
