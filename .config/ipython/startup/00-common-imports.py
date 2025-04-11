# flake8: noqa: F401
import re
from collections import defaultdict
from pathlib import Path

from rich import pretty

pretty.install()

try:
    import pendulum
except ImportError:
    print("Pendulum is not available")
