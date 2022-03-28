set -l subcommands add completion cred-process env exec help list login version write-to-credentials

function __fish_aws_okta_register_completion --inherit-variable subcommands
    set subcommand $argv[1]
    set description $argv[2]

    if not contains $subcommand $subcommands
        echo "$subcommand is not a aws-okta subcommand"
        exit
    end

    complete --command aws-okta --no-files --condition "not __fish_seen_subcommand_from $subcommands" --arguments $subcommand --description $description
end

# Register subcommands, pulled from aws-okta help
__fish_aws_okta_register_completion add                  'add your okta credentials'
__fish_aws_okta_register_completion completion           'Output shell completion code for the given shell (bash or zsh)'
__fish_aws_okta_register_completion cred-process         'cred-process generates a credential_process ready output'
__fish_aws_okta_register_completion env                  'env prints out export commands for the specified profile'
__fish_aws_okta_register_completion exec                 'exec will run the command specified with aws credentials set in the environment'
__fish_aws_okta_register_completion help                 'Help about any command'
__fish_aws_okta_register_completion list                 'list will show you the profiles currently configured'
__fish_aws_okta_register_completion login                'login will authenticate you through okta and allow you to access your AWS environment through a browser'
__fish_aws_okta_register_completion version              'print version'
__fish_aws_okta_register_completion write-to-credentials 'write-to-credentials writes credentials for the specified profile to the specified credentials file'

# help subcommand
complete -c aws-okta --no-files -n '__fish_seen_subcommand_from help' -a "$subcommands"

# env, exec, and login subcommands accept profile
function __fish_okta_complete_profiles -d 'Suggest profiles'
  cat ~/.aws/config | grep -e '^\[profile ' | awk -F'[] []' '{print $3}'
end

for subcommand in env exec login
    complete --command aws-okta --no-files -n "__fish_seen_subcommand_from $subcommand; and not __fish_seen_subcommand_from (__fish_okta_complete_profiles) --" -a "(__fish_okta_complete_profiles)"
end

# If we already have aws-okta exec <PROFILE>, then suggest the command delimiter
complete --command aws-okta --no-files --require-parameter -n '__fish_seen_subcommand_from exec; and __fish_seen_subcommand_from (__fish_okta_complete_profiles); and not __fish_seen_subcommand_from --' -a '--'
