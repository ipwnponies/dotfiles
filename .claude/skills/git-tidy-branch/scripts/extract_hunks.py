#!/usr/bin/env python3
"""
Extract specific hunks from git diff and generate a staging+commit script.

Usage:
    python extract_hunks.py commit-plan.json

Input: commit-plan.json with structure:
    {
      "base_ref": "main",
      "commits": [
        {
          "message": "refactor: extract helper",
          "hunks": [
            {"file": "src/foo.py", "hunk_indices": [0, 1]},
            {"file": "src/bar.py"}   <- omit hunk_indices to take whole file
          ]
        }
      ]
    }

Output:
    stage-and-commit.sh  (executable shell script)
    patches/             (patch files for hunk-split files)
"""

import json
import os
import re
import subprocess
import sys
from dataclasses import dataclass, field
from pathlib import Path


@dataclass
class Hunk:
    old_start: int
    old_count: int
    new_start: int
    new_count: int
    context_suffix: str
    lines: list = field(default_factory=list)

    @property
    def delta(self):
        added = sum(1 for l in self.lines if l.startswith('+'))
        removed = sum(1 for l in self.lines if l.startswith('-'))
        return added - removed


@dataclass
class FileDiff:
    header_lines: list = field(default_factory=list)
    hunks: list = field(default_factory=list)


def parse_diff(text):
    """Parse unified diff text into {filepath: FileDiff}.

    Keys are the NEW filename (b/ side), so renames are tracked under
    the post-reset working-tree name that `git add` expects.
    """
    files = {}
    cur_file = None
    cur_header = []
    cur_hunks = []
    cur_hunk = None

    for line in text.splitlines():
        if line.startswith('diff --git '):
            _flush(files, cur_file, cur_header, cur_hunks, cur_hunk)
            m = re.match(r'diff --git a/(.*) b/(.*)', line)
            cur_file = m.group(2) if m else None
            cur_header = [line]
            cur_hunks = []
            cur_hunk = None

        elif cur_hunk is None and cur_file is not None:
            if not line.startswith('@@ '):
                cur_header.append(line)
            else:
                cur_hunk = _parse_hunk_header(line)

        elif line.startswith('@@ '):
            if cur_hunk is not None:
                cur_hunks.append(cur_hunk)
            cur_hunk = _parse_hunk_header(line)

        elif cur_hunk is not None:
            cur_hunk.lines.append(line)

    _flush(files, cur_file, cur_header, cur_hunks, cur_hunk)
    return files


def _flush(files, filepath, header, hunks, last_hunk):
    if filepath is None:
        return
    if last_hunk is not None:
        hunks.append(last_hunk)
    files[filepath] = FileDiff(header_lines=list(header), hunks=list(hunks))


def _parse_hunk_header(line):
    m = re.match(r'@@ -(\d+)(?:,(\d+))? \+(\d+)(?:,(\d+))? @@(.*)', line)
    if not m:
        return None
    return Hunk(
        old_start=int(m.group(1)),
        old_count=int(m.group(2)) if m.group(2) is not None else 1,
        new_start=int(m.group(3)),
        new_count=int(m.group(4)) if m.group(4) is not None else 1,
        context_suffix=m.group(5),
    )


def build_partial_patch(file_diff, hunk_indices):
    """
    Build a patch for a subset of hunks in a file.
    Adjusts +line numbers to account for only the selected preceding hunks.
    """
    selected = sorted(set(hunk_indices))
    out = list(file_diff.header_lines)
    cumulative_delta = 0

    for idx in selected:
        hunk = file_diff.hunks[idx]
        adjusted_new_start = hunk.old_start + cumulative_delta
        old_part = f"-{hunk.old_start},{hunk.old_count}"
        new_part = f"+{adjusted_new_start},{hunk.new_count}"
        out.append(f"@@ {old_part} {new_part} @@{hunk.context_suffix}")
        out.extend(hunk.lines)
        cumulative_delta += hunk.delta

    return '\n'.join(out) + '\n'


def get_diff(base_ref):
    """Get the full working-tree diff (post git-reset-soft) or branch diff."""
    result = subprocess.run(['git', 'diff'], capture_output=True, text=True)
    if result.stdout.strip():
        return result.stdout

    merge_base = subprocess.run(
        ['git', 'merge-base', 'HEAD', base_ref],
        capture_output=True, text=True
    ).stdout.strip()

    ref = merge_base or base_ref
    result = subprocess.run(['git', 'diff', f'{ref}..HEAD'], capture_output=True, text=True)
    return result.stdout


def main():
    if len(sys.argv) < 2:
        print("Usage: extract_hunks.py commit-plan.json", file=sys.stderr)
        sys.exit(1)

    plan_path = Path(sys.argv[1]).resolve()
    with open(plan_path) as f:
        plan = json.load(f)

    base_ref = plan['base_ref']
    commits = plan['commits']

    diff_text = get_diff(base_ref)
    if not diff_text.strip():
        print("Error: no diff found. Is the working tree clean?", file=sys.stderr)
        sys.exit(1)

    file_diffs = parse_diff(diff_text)

    script_dir = plan_path.parent
    patch_dir = script_dir / 'patches'
    patch_dir.mkdir(exist_ok=True)

    script_lines = [
        '#!/bin/bash',
        'set -euo pipefail',
        '',
        f'BASE=$(git merge-base HEAD {base_ref} 2>/dev/null || echo "{base_ref}")',
        'echo "Resetting to $BASE ..."',
        'git reset --soft "$BASE"',
        # After soft reset the index still has everything staged.
        # Unstage so we can stage each commit group selectively.
        'git restore --staged .',
        '',
    ]

    any_patches = False

    for idx, commit in enumerate(commits):
        msg = commit['message']
        script_lines.append(f'# ── Commit {idx + 1}: {msg} ──')

        for file_spec in commit['hunks']:
            filepath = file_spec['file']
            hunk_indices = file_spec.get('hunk_indices')

            file_diff = file_diffs.get(filepath)

            if hunk_indices is None or file_diff is None or len(hunk_indices) == len(file_diff.hunks):
                script_lines.append(f'git add -- {_sh_quote(filepath)}')
            else:
                patch_content = build_partial_patch(file_diff, hunk_indices)
                safe_name = re.sub(r'[^\w.-]', '_', filepath)
                patch_file = patch_dir / f'commit-{idx + 1:02d}-{safe_name}.patch'
                with open(patch_file, 'w') as pf:
                    pf.write(patch_content)
                any_patches = True
                rel = os.path.relpath(patch_file, script_dir)
                script_lines.append(f'git apply --cached {_sh_quote(rel)}')

        script_lines.append(f'git commit -m {_sh_quote(msg)}')
        script_lines.append('')

    script_lines.append('echo "Done. New history:"')
    script_lines.append('git log --oneline')

    script_path = script_dir / 'stage-and-commit.sh'
    with open(script_path, 'w') as f:
        f.write('\n'.join(script_lines) + '\n')
    os.chmod(script_path, 0o755)

    print(f"Generated: {script_path}")
    if any_patches:
        print(f"Patches:   {patch_dir}/")


def _sh_quote(s):
    return "'" + s.replace("'", "'\\''") + "'"


if __name__ == '__main__':
    main()
