set -l completion_dir /usr/share/fish/completions/
test -d $completion_dir; or set completion_dir /usr/local/share/fish/vendor_completions.d/

source $completion_dir/task.fish
function __fish.task.list.project
    task _unique project
end
