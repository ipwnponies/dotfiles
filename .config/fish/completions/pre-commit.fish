function extend
    complete -r -f -c pre-commit -n '__pre-commit_using_command run' -a '(__pre-commit_hooks)' --description 'hook'

    function __pre-commit_using_command -d 'Test if any of target subcommands in use'
        set -l cmd (__pre-commit_subcommand)
        test $status -ne 0; and return 1

        # Test if subcommand we're watching for is called
        return (contains -- $cmd $argv)
    end

    function __pre-commit_subcommand -d 'Parse commandline for subcommand'
        set cmd (commandline -opc)
        set -l skip_next 1
        set -q cmd[2]; or return 1
        # Skip first word because it's "git" or a wrapper
        for c in $cmd[2..-1]
            switch $c
                # General options that belong to pre-commit
                case "--help" "-h" "--version" "-V"
                    return 1
                # We assume that any other token that's not an argument to a general option is a command
                case "*"
                    echo $c
                    return 0
            end
        end
        return 1
    end

    function __pre-commit_hooks -d 'List of pre-commit hooks for the repo'
        set pre_commit_yaml (git rev-parse --show-toplevel)'/.pre-commit-config.yaml'
        test -e $pre_commit_yaml; or return 1

        # Convert yaml to json, then get all hook names
        cat $pre_commit_yaml | \
        python -c 'import sys, yaml, json; print(json.dumps(yaml.safe_load(sys.stdin.read())))' | \
        jq -r '.repos[].hooks[].id'
    end
end

completions_load_upstream (status filename)
extend
