# Bundle Skills

Zips `.agents/skills/` (a set of vendored Claude Code plugins) together with
`.claude/CLAUDE.md` and publishes the result to the permanent `skills-latest`
GitHub release, so a fresh cloud environment can fetch one file to recreate
the Claude dev setup instead of cloning this repo or running
`claude plugin install` itself.

Runs on every push to `master` that touches `.agents/skills/**`,
`.claude/CLAUDE.md`, or this workflow, and can be triggered manually via
`workflow_dispatch`.

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

mkdir -p ~/.claude/
unzip -o /tmp/skills.zip -d ~/.claude/
rm /tmp/skills.zip

echo "Skills installed: $(ls ~/.claude/skills/)"
echo "CLAUDE.md installed: $([ -f ~/.claude/CLAUDE.md ] && echo yes || echo no)"
```

That's it — no `claude plugin install`, no marketplace registration, no
`GITHUB_TOKEN`. Every plugin currently bundled (`superpowers`, `context7`,
`compound-engineering`, `caveman`), every plain skill, and `~/.claude/CLAUDE.md`
land in place, ready for the next `claude` session in that environment.

Note the extract target changed from `~/.claude/skills/` to `~/.claude/` —
the zip now contains a top-level `skills/` dir plus `CLAUDE.md`, so unzipping
one level higher puts both in the right spot.
