function is_expired --description 'Return 0 if file is older than one week, missing, or older than any given watch file'
    set -l file $argv[1]
    set -l watch $argv[2..]
    test -f $file; or return 0

    for w in $watch
        test -e $w; and test $w -nt $file; and return 0
    end

    set -l ttl (math '60*60*24*7')
    set -l current_time (date +%s)
    # stat -c %Y is Linux; stat -f %m is macOS
    set -l file_age (stat -c %Y $file 2>/dev/null; or stat -f %m $file 2>/dev/null; or echo 0)

    test (math $current_time - $file_age) -gt $ttl
end
