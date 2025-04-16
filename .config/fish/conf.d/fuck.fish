function main
    # The default binding \cf is forward character. I hope to god I don't have to resort to this.
    # It's like the 90s all over again, vt420 and all.
    pay-respects fish --alias f | source
    bind \cf 'f; commandline -f repaint'
end

status --is-interactive; and main
