function copy_command_output_clipboard
    if test (count $argv) -eq 0
        set cmd (string split ' ' (history --max 1))
    else
        set cmd $argv
    end

    set stdout (mktemp)
    echo -e "\$ $cmd\n" | tee --append $stdout
    $cmd 2>&1 | tee --append $stdout
    pbcopy < $stdout
end
