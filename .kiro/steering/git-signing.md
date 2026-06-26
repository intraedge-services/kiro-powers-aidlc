---
inclusion: always
---
# Git Commit Signing — Steering Rule

**Scope**: All projects using this power

## Requirement

Every git commit created by the agent MUST be cryptographically signed. This applies to:
- Commits during Code Generation
- Commits during Build & Test
- Any ad-hoc commits the agent creates (e.g., fixing lint issues, updating configs)

## Enforcement

At session start (or first git operation), verify signing is configured:

```bash
git config --get user.signingkey
git config --get commit.gpgsign
```

If `user.signingkey` is empty or `commit.gpgsign` is not `true`:
1. Warn the user immediately
2. Provide setup guidance:
   - `gpg --full-generate-key` (generate key)
   - `gpg --list-secret-keys --keyid-format=long` (find key ID)
   - `git config --global user.signingkey <KEY_ID>` (set key)
   - `git config --global commit.gpgsign true` (enable auto-signing)
3. Do NOT create any commits until signing is confirmed

## SSH Signing Alternative

SSH keys are equally valid. If `gpg.format=ssh` is set and `user.signingkey` points to a valid SSH key file, the requirement is satisfied.

## Non-Blocking Exceptions

- If the project is in a CI environment where signing is managed externally, note this in audit.md and proceed
- If the user explicitly declines signing (logged in audit.md with justification), proceed with a warning on each commit
