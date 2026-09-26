function main
    type -q pay-respects; or return

    # The default binding \cf is forward character. I hope to god I don't have to resort to this.
    # It's like the 90s all over again, vt420 and all.
    pay-respects fish --alias f | source
    bind \cf 'f; commandline -f repaint'
end

status --is-interactive; and main

# Helpers are global; erase them so they don't shadow commands (e.g. coreutils `install`) later
functions --erase main
