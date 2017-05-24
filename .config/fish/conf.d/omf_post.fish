if test -e $XDG_CONFIG_HOME/fish/conf.d/omf.fish
    omf install
end

# plugin-expand

# Bash's ^foo^bar^ substitution
expand-word -p '^s/..*/.*$' -e 'echo -n "$history[1]" | sed -e (commandline -t)/g'

# Bash's !! history substitution
expand-word -p '^!!$' -e 'echo -n $history[1]'

# Bash's !-n history substitution
expand-word -p '^!-[0-9]$' -e 'echo -n $history[(string sub -s -1 (commandline -t))]'
