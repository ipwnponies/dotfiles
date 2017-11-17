from __future__ import (unicode_literals, division, absolute_import, print_function)

import re
import socket
import subprocess

ssh_regex = re.compile('ssh.*?\s(?:(?P<user>\S+)@)?(?P<host>\S+)')


def hostname(pl):
    pane_cmd = subprocess.check_output( [
        'tmux',
        'display-message',
        '-p',
        '"#{pane_current_command}"',
    ]).decode('utf-8')

    pane_cmd = pane_cmd.strip().replace('"', '')
    if 'ssh' == pane_cmd:
        return get_remote_host()
    else:
        return socket.gethostname()


def get_remote_host():
    pane_pid = subprocess.check_output( [
        'tmux',
        'display-message',
        '-p', '"#{pane_pid}"',
    ]).decode('utf-8')

    pane_pid = pane_pid.strip().replace('"', '')

    child_processes =subprocess.check_output( [
        'ps',
        '-h',
        '-o', 'command',
        '--ppid', pane_pid,
    ]).decode('utf-8').splitlines()

    child_process = next(cmd for cmd in child_processes if 'ssh' in cmd)

    match = ssh_regex.search(child_process)
    user, host = match.group('user'), match.group('host')

    return '{}@{}'.format(user, host) if user else host
