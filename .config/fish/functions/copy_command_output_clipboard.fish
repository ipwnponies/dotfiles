function copy_command_output_clipboard
    set stdout (mktemp)
    echo -e "\$ $argv\n" >> $stdout
    $argv >> $stdout
    pbcopy < $stdout
end
