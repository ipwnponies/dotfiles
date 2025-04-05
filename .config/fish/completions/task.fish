function extend
    # Shadow upstream function. Add filter for recent or active projects
    function __fish.task.list.project
        task +PENDING or end.after:'today - 3 month' _unique project
    end
end

completions_load_upstream (status filename)
extend
