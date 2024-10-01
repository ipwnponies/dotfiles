function eza -d 'eza but with default options'
    # This is notably missing the --long option. These options are inert otherwise, which is the default for eza
    set display_options --grid --classify --colour-scale --icons --hyperlink
    set long_options --time-style=long-iso --header
    command eza $display_options $long_options $argv
end
