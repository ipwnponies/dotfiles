# Add auto-completion and a stored history file of commands to your Python
# interactive interpreter. Requires Python 2.0+, readline. Autocomplete is
# bound to the Esc key by default (you can change it - see readline docs).
#
# Store the file in ~/.pythonrc.py, and set an environment variable to point
# to it:  "export PYTHONSTARTUP=/home/user/.pythonrc.py" in bash.
#
# Note that PYTHONSTARTUP does *not* expand "~", so you have to put in the
# full path to your home directory.

import atexit
import os
import readline
import rlcompleter

histFilePath = os.path.expanduser('~/.python_history')

# load an existing python history file.
try:
	readline.read_history_file(histFilePath)
except IOError:
	pass

atexit.register(readline.write_history_file, histFilePath)

readline.parse_and_bind('tab: complete')

del os, atexit, readline, rlcompleter, histFilePath
