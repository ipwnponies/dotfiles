if status --is-interactive; and set -q conf_wait
    set start (date +%s)
    set njobs (count (jobs -p))
    set jobs_desc (string join ', ' (jobs --command))
    printf '%s' (set_color brblue)'⏳ Waiting for '$njobs' job(s): '$jobs_desc(set_color normal)

    wait

    set elapsed (math (date +%s) - $start)
    printf '\r\033[K%s\n' (set_color brgreen)'✓ Done in '$elapsed's: '$njobs' job(s): '$jobs_desc(set_color normal)
end
