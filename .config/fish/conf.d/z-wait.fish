if status --is-interactive; and set -q conf_wait
    echo Waiting patiently for all scripts to complete...
    wait
end
