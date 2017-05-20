# Path to z plugin
set -x Z_SCRIPT_PATH $XDG_CONFIG_HOME/z/z/z.sh

if status --is-interactive; and not test -e $XDG_CONFIG_HOME/fish/conf.d/omf.fish
    $XDG_CONFIG_HOME/fish/plugins/oh-my-fish/bin/install --noninteractive --offline
end
