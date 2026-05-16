# Claude Global Instructions

## Personal Knowledge Store

`~/.agents/docs/solutions/` — documented solutions to past problems (bugs, best practices, workflow patterns), organized by category with YAML frontmatter (`module`, `tags`, `problem_type`). Relevant when debugging or working in a documented area.

When running `/ce-compound`, write docs to `~/.agents/docs/solutions/<category>/` instead of the default `docs/solutions/`.

## Session Learning Capture

Watch for friction during any session:
- User corrected a pattern or preference (once or repeatedly)
- Non-obvious solution was found through investigation
- User stated a convention or preference they want going forward
- A script was written and used but not persisted
- A skill was invoked and its instructions were wrong or incomplete

When a session reaches a natural end and any friction was observed, offer to run `/post-session-learning` before the user leaves. One short sentence is enough: "Want me to capture what we learned so this is automatic next time?" Do not offer if the session had no friction worth capturing (pure Q&A, trivial tasks).
