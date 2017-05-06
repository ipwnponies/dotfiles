# Path to z plugin
set -gx Z_SCRIPT_PATH ~/.config/z/z/z.sh

if status --is-interactive; and not test -e ~/.config/fish/conf.d/omf.fish
    ~/.config/fish/plugins/oh-my-fish/bin/install --noninteractive --offline
end
