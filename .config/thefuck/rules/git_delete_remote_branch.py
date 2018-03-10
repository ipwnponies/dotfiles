import re

from thefuck.utils import replace_argument


def match(command):
    command_regex = re.compile('^git (pu|push)( \w*)? --delete')

    # Example failure
    # error: unable to delete 'origin/awesome-cool-feature': remote ref does not exist
    # error: failed to push some refs to 'git@github.com:example'

    return command_regex.match(command.script) and 'error: unable to delete' in command.stderr and 'remote ref does not exist' in command.stderr


def get_new_command(command):
    return command.script.replace('origin/', '')
