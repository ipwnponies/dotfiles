# Function to help load upstream completions
# Fish stops completion search after the first match. Adding a user custom completions shadows the vendored
# one.
# We often want to extend vendor completions, not shadow them.
function completions_load_upstream --description 'Load upstream completions'
    set completion_file $argv[1]
    set search_paths $fish_complete_path

    set this_dir (contains --index (dirname $completion_file) $search_paths)
    if test $status
        # Remove this directory from the search paths
        set --erase search_paths[$this_dir]
    end

    for i in $search_paths
        set upstream_completion $i/(basename $completion_file)
        if test -e $upstream_completion
            source $upstream_completion

            # Stop after first completion. This matches fish completion search behaviour
            return
        end
    end

    # If we reach this point, we didn't find the completion file
    return 1
end
