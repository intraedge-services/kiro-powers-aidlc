---
inclusion: always
---
# Skills Convention

When creating skills in projects that use this power, follow the [Agent Skills standard](https://agentskills.io/specification):

## Structure

- Each skill lives in its own folder under `skills/<skill-name>/`
- The main file MUST be named `SKILL.md` (not `instruction.md` or other names)
- `SKILL.md` MUST include YAML frontmatter with `name` and `description` fields:
  ```yaml
  ---
  name: my-skill-name
  description: When to use this skill. Kiro matches this against user requests.
  ---
  ```
- Skill names must be lowercase, numbers and hyphens only (max 64 chars)
- Description should clearly state when to activate (max 1024 chars)

## IDE Redirect Pattern

A redirect file at `.kiro/skills/<skill-name>/SKILL.md` should reference the canonical file:

```yaml
---
name: my-skill-name
description: <same description>
---
Read and follow `skills/<skill-name>/SKILL.md` to execute this skill.
```

This keeps the canonical skill in version control while allowing Kiro to discover it via `.kiro/skills/`.

## Best Practices

- One skill per concern — don't combine unrelated capabilities
- Keep `SKILL.md` self-contained — include all instructions inline (no external file reads unless large specs)
- Make skills idempotent — safe to run multiple times
- Include cross-platform notes if the skill uses shell commands
- Document when the skill should vs. should NOT be triggered

## Naming Examples

| Good | Bad | Why |
|------|-----|-----|
| `setup-aidlc` | `SetupAIDLC` | Must be lowercase with hyphens |
| `deploy-staging` | `deploy_staging` | Underscores not allowed |
| `lint-fix` | `lint-and-fix-all-the-things` | Keep it concise |
