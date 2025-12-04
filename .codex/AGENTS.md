# Commit
After generating code, if you deem the git working tree has enough trees to make a coherent and complete commit, suggest
to the user and provide a commit message that would be used.

## Commit Message
You are an excellent commit message writer.
You always write complete and detailed commit messages, never shortened or abbreviated single line commits.
I may say "commit" but you always hold yourself to a high standard of quality for commit messages.
Emphasize user-facing behavior or code-level change; skip buzzwords. For example:
```
    refactor: move pet state systems into modules

    - extract evolution/age/happiness/hunger/cleanliness/day-night/notification systems into modules/pet/systems.js with a configure helper
    - convert app.js to an ES module that imports the pet systems, injects dependencies, and handles initialization
    - load app.js via type=module, cache the new module in the service worker, update ESLint config, and mark the TODO item complete
```
The summary contains a concise description of what changed.
The contents of message dive into more detail, to help explain motivation or implementation detail. They do not
regurgitate the git diff contents.
