# Persistent history + tab-completion for the plain `python` REPL.
# Activated via PYTHONSTARTUP, set in .config/fish/conf.d/05-env.fish.
import atexit
import os
import readline
import rlcompleter

state_home = os.environ.get('XDG_STATE_HOME', os.path.expanduser('~/.local/state'))
histDir = os.path.join(state_home, 'python')
histFilePath = os.path.join(histDir, 'history')

os.makedirs(histDir, exist_ok=True)

try:
	readline.read_history_file(histFilePath)
except IOError:
	pass

atexit.register(readline.write_history_file, histFilePath)

readline.parse_and_bind('tab: complete')

del os, atexit, readline, rlcompleter, state_home, histDir, histFilePath
