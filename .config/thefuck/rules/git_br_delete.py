from thefuck.utils import replace_argument


def match(command):
    return ('br -d' in command.script and 'If you are sure you want to delete it' in command.stderr)


def get_new_command(command):
    return replace_argument(command.script, '-d', '-D')
