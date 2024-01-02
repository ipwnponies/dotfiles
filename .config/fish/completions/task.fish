set -l completion_dir /usr/share/fish/completions/
test -d $completion_dir; or set completion_dir /usr/local/share/fish/vendor_completions.d/
# Brew installation has changed for apple silicon, now in /opt/homebrew
test -d $completion_dir; or set completion_dir /opt/homebrew/share/fish/vendor_completions.d/

if test ! -d $completion_dir
    echo "Could not find fish vendor completion dir"
    exit
end

source $completion_dir/task.fish

# Shadow upstream function. Add filter for recent or active projects
function __fish.task.list.project
    task +PENDING or end.after:'today - 3 month' _unique project
end
