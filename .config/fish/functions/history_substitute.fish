function history_substitute --description "Load up recent command history into EDITOR. This is the poor man's history substitution."

    if date --version ^ /dev/null
        # Return all commands used in last 20 mins
        set -l start_time (date -d '20 min ago' +%s)
        set history_lines (history --max 10 --show-time='%s ' | awk '$1 > $start_time')
    else
        # BSD date does not support --version. It also doesn't do relative dates.
        # Return last ten lines
        set history_lines (history --max 10)
    end

    # Replace current buffer with history
    commandline -r $history_lines
    edit_command_buffer

    if test (commandline -b | wc -l) -gt 2
        # If there are more than 2 lines, we probably aborted history substitution
        commandline -r ''
    end
end
