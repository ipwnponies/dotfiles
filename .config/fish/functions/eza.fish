function eza -d 'eza but with default options'
    # This is notably missing the --long option. These options are inert otherwise, which is the default for exa but
    set long_options --grid --colour-scale --git --time-style=long-iso
    command eza --classify --icons $long_options $argv
end
