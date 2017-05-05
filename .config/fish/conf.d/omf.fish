# Path to Oh My Fish install.
set -q XDG_DATA_HOME
  and set -gx OMF_PATH "$XDG_DATA_HOME/omf"
  or set -gx OMF_PATH "$HOME/.local/share/omf"

# Path to z plugin
set -g Z_SCRIPT_PATH ~/.config/z/z/z.sh

# Load Oh My Fish configuration.
source $OMF_PATH/init.fish
