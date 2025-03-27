for i in $fish_complete_path
    if test $i = (dirname (realpath (status filename)))
        # Ignore this file, no recursive sourcing
        continue
    end

    set -l task_completion $i/task.fish
    if test -e $task_completion
        source $task_completion
        break
    end
end

# Shadow upstream function. Add filter for recent or active projects
function __fish.task.list.project
    task +PENDING or end.after:'today - 3 month' _unique project
end
