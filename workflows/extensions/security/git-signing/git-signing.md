# Git Commit Signing Extension

**Type**: Always Enforced (no opt-in prompt)

This extension ensures all commits produced during AIDLC workflows are cryptographically signed using GPG (or SSH signing keys). Unsigned commits are blocked until signing is properly configured.

---

## Rule GIT-SIGN-01: Verify Signing Configuration at Workspace Detection

### Rule
At the Workspace Detection stage, the agent MUST verify that GPG commit signing is configured in the user's git environment. If signing is NOT configured, the workflow MUST pause and guide the user through setup before proceeding to any stage that produces commits.

**Verification command**: `git config --get user.signingkey`

If this returns empty or fails, signing is not configured.

### Verification
- [ ] `git config --get user.signingkey` returns a non-empty value
- [ ] `git config --get commit.gpgsign` returns `true`
- [ ] If either check fails: workflow pauses with setup guidance (see Rule GIT-SIGN-02)
- [ ] If both pass: workflow proceeds normally

---

## Rule GIT-SIGN-02: Guided Setup for Missing Configuration

### Rule
When signing is not configured, the agent MUST present clear setup instructions and wait for the user to confirm completion before proceeding. The agent MUST NOT skip this step or proceed without signing.

**Setup instructions to present**:

```
⚠️ GPG commit signing is not configured. All AIDLC commits must be signed.

Setup steps:

1. Generate a GPG key (if you don't have one):
   gpg --full-generate-key

2. List your keys and copy the key ID:
   gpg --list-secret-keys --keyid-format=long

3. Configure git to use your key:
   git config --global user.signingkey <YOUR_KEY_ID>
   git config --global commit.gpgsign true

4. (Optional) Export your public key for GitHub/GitLab:
   gpg --armor --export <YOUR_KEY_ID>

After completing setup, confirm to continue the workflow.
```

### Verification
- [ ] Setup instructions presented to user when signing is missing
- [ ] Agent waits for explicit user confirmation before proceeding
- [ ] After user confirms: re-run `git config --get user.signingkey` to validate
- [ ] If still not configured after confirmation: warn again (do not loop infinitely — allow after 2 attempts with a logged warning)

---

## Rule GIT-SIGN-03: Enforce Signed Commits During Code Generation

### Rule
Any git commit created during AIDLC Code Generation or Build & Test stages MUST include the `-S` flag (or rely on `commit.gpgsign=true` being set). The agent MUST NOT create commits without signing.

### Verification
- [ ] All `git commit` commands include `-S` flag OR `commit.gpgsign` is globally set to `true`
- [ ] No unsigned commits are produced during AIDLC stages
- [ ] If a commit fails due to signing issues: surface the error clearly and do not retry without fixing

---

## Rule GIT-SIGN-04: SSH Signing Key Alternative

### Rule
SSH signing keys are an acceptable alternative to GPG. If the user has configured `gpg.format=ssh` and a valid `user.signingkey` pointing to an SSH key, this satisfies the signing requirement.

### Verification
- [ ] If `gpg.format` is `ssh`: accept SSH key path as valid signing key
- [ ] SSH signing key file exists at the configured path
- [ ] No preference is enforced between GPG and SSH — either is acceptable

---

## Enforcement

This extension is checked at the following AIDLC stages:

| Stage | Rules Checked |
|-------|--------------|
| Workspace Detection | GIT-SIGN-01, GIT-SIGN-02, GIT-SIGN-04 |
| Code Generation | GIT-SIGN-03 |
| Build and Test | GIT-SIGN-03 |

The Workspace Detection check is a **blocking gate** — the workflow cannot proceed to any commit-producing stage until signing is verified.
