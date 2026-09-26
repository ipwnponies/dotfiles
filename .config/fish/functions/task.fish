# This is a function that depends on taskwarrior
# Don't accidentally shadow task commands or existing functions!

function taskdepends -d 'Add a task that depends on another task'
    set parent_task $argv[1]

    set inherit_properties due priority project scheduled tags until wait
    set add_args
    for prop in $inherit_properties
        # Join output so an empty value can't collapse to zero elements
        set -l value (task _get $parent_task.$prop | string collect)
        test -n "$value"; and set -a add_args $prop:$value
    end

    echo task add depends:$parent_task $add_args $argv[2..]
    task add depends:$parent_task $add_args $argv[2..]
end
