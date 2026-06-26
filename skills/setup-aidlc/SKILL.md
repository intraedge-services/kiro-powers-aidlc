---
name: setup-aidlc
description: Set up AI-DLC (AI-Driven Development Life Cycle) in the current project. Use when you need to install or update AI-DLC workflows, configure IDE steering files, or bootstrap a project with AI-DLC support.
---
# Skill: Setup AI-DLC

Set up AI-DLC (AI-Driven Development Life Cycle) in the current project. This skill automates setup for any IDE/agent environment, with upgrade detection and cross-platform support.

## Usage

Invoke this skill to configure AI-DLC in any project. The skill is idempotent — safe to run multiple times (it detects existing installs and handles upgrades).

## Optional: Version

If the user specifies a version (e.g., "set up AI-DLC v1.1.0"), use that version. Otherwise, default to the **latest** release.

---

## Instructions

### 1. Check for Existing Install

Before installing, check if AI-DLC is already set up:

```bash
# Check version file
cat .aidlc-version 2>/dev/null || echo "not-installed"

# Check for state file
test -f aidlc-docs/aidlc-state.md && echo "state-exists"
```

- If `.aidlc-version` matches the target version: report "Already up to date" and exit
- If `.aidlc-version` exists but is older: proceed with upgrade (inform user)
- If neither file exists: proceed with fresh install

### 2. Download the AI-DLC Release

Determine the download URL:

- **If a specific version is requested**, construct the URL directly:
  ```
  https://github.com/awslabs/aidlc-workflows/releases/download/v<VERSION>/ai-dlc-rules-v<VERSION>.zip
  ```

- **If no version specified (default to latest)**, use the GitHub API:
  ```bash
  curl -sL https://api.github.com/repos/awslabs/aidlc-workflows/releases/latest \
    | grep -o '"browser_download_url": *"[^"]*"' \
    | head -1 \
    | cut -d'"' -f4
  ```

Then download, extract, and install:

```bash
# Mac/Linux:
curl -sL -o /tmp/aidlc-rules.zip "<DOWNLOAD_URL>"
unzip -o /tmp/aidlc-rules.zip -d /tmp/aidlc-release
mkdir -p .aidlc
rm -rf .aidlc/aidlc-rules
cp -r /tmp/aidlc-release/aidlc-rules .aidlc/aidlc-rules
rm -rf /tmp/aidlc-rules.zip /tmp/aidlc-release

# Windows (WSL): Same as Mac/Linux
# Windows (native PowerShell):
#   Invoke-WebRequest -Uri "<DOWNLOAD_URL>" -OutFile "$env:TEMP\aidlc-rules.zip"
#   Expand-Archive -Path "$env:TEMP\aidlc-rules.zip" -DestinationPath "$env:TEMP\aidlc-release" -Force
#   New-Item -ItemType Directory -Force -Path ".aidlc"
#   Remove-Item -Recurse -Force ".aidlc\aidlc-rules" -ErrorAction SilentlyContinue
#   Copy-Item -Recurse "$env:TEMP\aidlc-release\aidlc-rules" ".aidlc\aidlc-rules"
#   Remove-Item "$env:TEMP\aidlc-rules.zip", "$env:TEMP\aidlc-release" -Recurse -Force
```

### 3. Create the Appropriate IDE Steering/Rules File

Auto-detect which IDE or agent is running and create the corresponding file. Pick the **first match**:

| IDE / Agent | Detection | File to create |
|---|---|---|
| Kiro IDE or Kiro CLI | `.kiro/` directory exists | `.kiro/steering/ai-dlc.md` |
| Amazon Q Developer | `.amazonq/` directory exists | `.amazonq/rules/ai-dlc.md` |
| Antigravity | `.agent/` directory exists | `.agent/rules/ai-dlc.md` |
| Cursor | `.cursor/` directory exists | `.cursor/rules/ai-dlc.mdc` (with frontmatter) |
| Cline | `.clinerules/` directory exists | `.clinerules/ai-dlc.md` |
| Claude Code | `CLAUDE.md` exists | `CLAUDE.md` (append) |
| GitHub Copilot | `.github/` directory exists | `.github/copilot-instructions.md` |
| Any other agent | Default fallback | `AGENTS.md` |

**File content** (for all except Cursor):
```
When the user invokes AI-DLC, read and follow
`.aidlc/aidlc-rules/aws-aidlc-rules/core-workflow.md` to start the workflow.
```

**For Cursor only**, prepend YAML frontmatter:
```
---
description: "AI-DLC workflow"
alwaysApply: true
---
When the user invokes AI-DLC, read and follow
`.aidlc/aidlc-rules/aws-aidlc-rules/core-workflow.md` to start the workflow.
```

### 4. Update .gitignore

Unless the user explicitly asks you **not** to:
- If `.gitignore` exists and does not already contain `.aidlc`: append `.aidlc` to it
- If `.gitignore` does not exist: create it with `.aidlc` as its content
- If `.aidlc` is already in `.gitignore`: do nothing

### 5. Write Version File

```bash
echo "<VERSION>" > .aidlc-version
```

### 6. Confirm

Tell the user:
- Which steering/rules file was created (and for which IDE)
- That `.aidlc` is gitignored (or that it was skipped if they asked not to)
- The AI-DLC version that was installed
- Whether this was a fresh install or upgrade

---

## Idempotency

This skill is safe to run multiple times:
- `.aidlc/aidlc-rules/` is replaced with the freshly downloaded version on each run
- The steering/rules file is overwritten (content is static)
- `.gitignore` is only appended to if `.aidlc` is not already present
- Version file is always updated to reflect current version

## Cross-Platform Notes

- Mac/Linux: All commands work natively
- Windows (WSL): All commands work natively inside WSL
- Windows (native): Use PowerShell equivalents shown in comments above
- `curl` and `unzip` are required (pre-installed on macOS; `sudo apt install unzip` on Linux)
