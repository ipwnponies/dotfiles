# This is a function that depends on taskwarrior
# Don't accidentally shadow task commands or existing functions!

function taskdepends -d 'Add a task that depends on another task'
    set parent_task $argv[1]

    set inherit_properties due priority project scheduled tags until wait
    set inherit_values

    for prop in $inherit_properties
        set inherit_values $inherit_values (task _get $parent_task.$prop)
    end

    set add_args
    for prop in $inherit_properties
        if set -l index (contains -i -- $prop $inherit_properties)
            set value $inherit_values[$index]
            test -n $value; and set add_args $add_args $prop:$value
        end
    end

    echo task add $add_args $argv[2..]
    task add $add_args $argv[2..]
end
