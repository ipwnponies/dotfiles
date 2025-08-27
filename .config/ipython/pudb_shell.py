#!/usr/bin/env python
"""
IPython initialization script for PuDB
This file will be executed when PuDB starts an IPython shell
"""

import os

from pathlib import Path

from IPython.terminal.embed import InteractiveShellEmbed


def pudb_shell(_globals, _locals):
    # Global scope might be useful for the modules imports. But it's also polluted as shit
    # Local scope is tighter but might be annoying if you lack tools

    shell = InteractiveShellEmbed(user_ns=_locals.copy())

    xdg_config_home = Path(os.environ.get("XDG_CONFIG_HOME", Path.home() / ".config"))
    # Manually execute all startup scripts
    startup_dir = xdg_config_home / "ipython" / "startup"
    for fname in sorted(startup_dir.glob("*.py")):
        with open(fname) as f:
            shell.run_cell(f.read())

    shell()
