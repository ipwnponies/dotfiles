# Bundle Skills

Zips `.agents/skills/` together with a set of vendored Claude Code plugins and
publishes the result to the permanent `skills-latest` GitHub release, so a
fresh cloud environment can fetch one file instead of cloning this repo or
running `claude plugin install` itself.

Runs on every push to `master` that touches `.agents/skills/**` or this
workflow, and can be triggered manually via `workflow_dispatch`.

Plugins are vendored by running the real `claude` CLI in the runner
(`claude plugin marketplace add` + `claude plugin install`), then copying
whatever lands in `~/.claude/plugins/cache/...` into `.agents/skills/<name>/`.
That folder still has its `.claude-plugin/plugin.json` manifest, so once it's
unzipped into `~/.claude/skills/` on the target machine, Claude Code
auto-loads it as a full plugin (skills, hooks, MCP servers, etc.) with no
install or registration step needed — see "Skills-directory plugins" in the
[Claude Code plugins reference](https://code.claude.com/docs/en/plugins-reference).

To add another plugin, add a line to `PLUGINS` (and to `MARKETPLACES` if it's
not already on `claude-plugins-official`) in the `Install plugins` step.

## Cloud environment setup script

Paste this into a cloud environment's setup script to install everything this
workflow publishes:

```bash
#!/usr/bin/env bash
set -euo pipefail

curl -sfL "https://github.com/ipwnponies/dotfiles/releases/download/skills-latest/skills.zip" \
  -o /tmp/skills.zip

mkdir -p ~/.claude/skills/
unzip -o /tmp/skills.zip -d ~/.claude/skills/
rm /tmp/skills.zip

echo "Skills installed: $(ls ~/.claude/skills/)"
```

That's it — no `claude plugin install`, no marketplace registration, no
`GITHUB_TOKEN`. Every plugin currently bundled (`superpowers`, `context7`,
`compound-engineering`, `caveman`) and every plain skill lands in
`~/.claude/skills/` ready to use on the next `claude` session in that
environment.
