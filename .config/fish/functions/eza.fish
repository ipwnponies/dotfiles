function eza -d 'eza but with default options' --wraps eza
    if not isatty stdout
        command eza $argv
        return
    end

    # This is notably missing the --long option. These options are inert otherwise, which is the default for eza
    set display_options --classify --colour-scale --icons --hyperlink
    set long_options --time-style=long-iso

    set full_args $display_options $long_options $argv

    if begin contains -- --long $full_args; or contains -- -l $full_args; end;
        and begin contains -- --grid $full_args; or contains -- -G $full_args; end
        echo "Cannot use --grid and --long together, this hides the symlink targets"
        return 1
    else if begin contains -- --header $full_args; or contains -- -h $full_args; end;
        and contains -- --icons $full_args
        echo "Cannot use --header and --icons together, this ignores --grid"
        return 1
    end
    command eza $full_args
end
