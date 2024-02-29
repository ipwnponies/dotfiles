function copy_command_output_clipboard
    if test (count $argv) -eq 0
        set cmd (string split ' ' (history --max 1))
    else
        set cmd $argv
    end

    set stdout (mktemp)
    echo -e "\$ $argv\n" >> $stdout
    $argv >> $stdout
    pbcopy < $stdout
end
