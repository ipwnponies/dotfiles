if status --is-interactive
    set -x LESS_TERMCAP_mb (printf "\e[01;31m")                 # Begins blinking.
    set -x LESS_TERMCAP_md (printf "\e[1;38;5;48m")             # Begins bold.
    set -x LESS_TERMCAP_me (printf "\e[0m")                     # Ends mode.
    set -x LESS_TERMCAP_se (printf "\e[0m")                     # Ends standout-mode.
    set -x LESS_TERMCAP_so (printf "\e[48;5;19m\e[38;5;155m")   # Begins standout-mode.
    set -x LESS_TERMCAP_ue (printf "\e[0m")                     # Ends underline.
    set -x LESS_TERMCAP_us (printf "\e[38;5;190m")              # Begins underline.
end
