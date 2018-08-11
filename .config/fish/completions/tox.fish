complete -f -c tox -s e -a '(_fish_tox_envlist | fzf_complete)' --description 'env list'

function _fish_tox_envlist
    # Pattern for tox environment section
    set tox_env_section '\[testenv:\([^]]*\)]'

    # Grep out section header and get only the environment name
    cat tox.ini | sed -n -e "/$tox_env_section/ {s/$tox_env_section/\1/; p}"
end
