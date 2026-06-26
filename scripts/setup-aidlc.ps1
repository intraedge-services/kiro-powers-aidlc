# ══════════════════════════════════════════════════════════════════════════════
# AIDLC Bootstrap — Zero-Prompt Setup (PowerShell)
# ══════════════════════════════════════════════════════════════════════════════
#
# Windows-native equivalent of setup-aidlc.sh
# Auto-detects everything from your workspace. No questions asked.
#
# Usage:
#   cd C:\path\to\your-project
#   & path\to\kiro-powers-aidlc\scripts\setup-aidlc.ps1
#
# Override auto-detection with parameters:
#   .\setup-aidlc.ps1 -Org NAME -Repo NAME -Board NUMBER -Lead USER -Lang LANGUAGE -Force
#
# ══════════════════════════════════════════════════════════════════════════════

param(
    [string]$Org = "",
    [string]$Repo = "",
    [string]$Board = "",
    [string]$Lead = "",
    [string]$Lang = "",
    [switch]$Interactive,
    [switch]$Force
)

$ErrorActionPreference = "Continue"

# ── Current Power Version ────────────────────────────────────────────────────
$AIDLC_POWER_VERSION = "1.1.0"

# ── Helpers ──────────────────────────────────────────────────────────────────
function Write-Info($msg) { Write-Host "  i  $msg" -ForegroundColor Blue }
function Write-Success($msg) { Write-Host "  +  $msg" -ForegroundColor Green }
function Write-Warn($msg) { Write-Host "  !  $msg" -ForegroundColor Yellow }
function Write-Err($msg) { Write-Host "  x  $msg" -ForegroundColor Red }

# ── Resolve paths ────────────────────────────────────────────────────────────
$WorkspaceRoot = Get-Location
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$PowerDir = Split-Path -Parent $ScriptDir

if (-not (Test-Path "$PowerDir\workflows") -or -not (Test-Path "$PowerDir\POWER.md")) {
    $PowerDir = ""
}

# ══════════════════════════════════════════════════════════════════════════════
# UPGRADE DETECTION
# ══════════════════════════════════════════════════════════════════════════════

$InstalledVersion = ""
$IsFreshInstall = $true

if (Test-Path ".aidlc-version") {
    $InstalledVersion = (Get-Content ".aidlc-version" -Raw).Trim()
    $IsFreshInstall = $false
}
elseif (Test-Path "aidlc-docs\aidlc-state.md") {
    $match = Select-String -Path "aidlc-docs\aidlc-state.md" -Pattern "AIDLC Version: (.*)" -ErrorAction SilentlyContinue
    if ($match) {
        $InstalledVersion = $match.Matches.Groups[1].Value.Trim()
        $IsFreshInstall = $false
    }
    elseif (Test-Path ".kiro\steering\project-config.md") {
        $InstalledVersion = "0.0.0"
        $IsFreshInstall = $false
    }
}

if (-not $IsFreshInstall) {
    if ($InstalledVersion -eq $AIDLC_POWER_VERSION) {
        Write-Host ""
        Write-Host "  AIDLC already up to date (v$AIDLC_POWER_VERSION)" -ForegroundColor Green
        Write-Host ""
        Write-Host "  Nothing to do. Your workspace is current." -ForegroundColor DarkGray
        Write-Host ""
        exit 0
    }

    Write-Host ""
    Write-Host "  AIDLC Upgrade Available" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  Installed: v$InstalledVersion" -ForegroundColor Yellow
    Write-Host "  Available: v$AIDLC_POWER_VERSION" -ForegroundColor Green
    Write-Host ""

    if (-not $Force) {
        $answer = Read-Host "  Upgrade from v$InstalledVersion to v$AIDLC_POWER_VERSION? (y/n)"
        if ($answer -notmatch "^[Yy]$") {
            Write-Info "Upgrade cancelled. No files were changed."
            exit 0
        }
    }
    else {
        Write-Info "Force flag set - proceeding with upgrade"
    }
    Write-Host ""
}

# ══════════════════════════════════════════════════════════════════════════════
# AUTO-DETECTION
# ══════════════════════════════════════════════════════════════════════════════

Write-Host ""
Write-Host "  AIDLC Setup - auto-detecting project configuration" -ForegroundColor Cyan
Write-Host ""

# ── Git Remote ───────────────────────────────────────────────────────────────
$Provider = ""
if (-not $Org -or -not $Repo) {
    $remoteUrl = git remote get-url origin 2>$null
    if ($remoteUrl) {
        if ($remoteUrl -match "github\.com") { $Provider = "github" }
        elseif ($remoteUrl -match "gitlab") { $Provider = "gitlab" }
        elseif ($remoteUrl -match "bitbucket") { $Provider = "bitbucket" }
        elseif ($remoteUrl -match "dev\.azure\.com") { $Provider = "azure-devops" }
        else { $Provider = "github" }

        if (-not $Org) {
            $Org = $remoteUrl -replace '.*[:/]([^/]+)/[^/]+(\.git)?$', '$1'
        }
        if (-not $Repo) {
            $Repo = $remoteUrl -replace '.*[:/][^/]+/([^.]+)(\.git)?$', '$1'
        }
    }
}
if (-not $Provider) { $Provider = "github" }

$DefaultBranch = git symbolic-ref --short refs/remotes/origin/HEAD 2>$null
if ($DefaultBranch) { $DefaultBranch = $DefaultBranch -replace "^origin/", "" }
if (-not $DefaultBranch) { $DefaultBranch = "main" }

$ProjectName = if ($Repo) { $Repo } else { Split-Path -Leaf $WorkspaceRoot }

# ── gh CLI ───────────────────────────────────────────────────────────────────
if (-not $Lead) {
    $Lead = gh api user --jq '.login' 2>$null
}
if (-not $Board -and $Org) {
    $Board = gh project list --owner $Org --format json --jq '.[0].number' 2>$null
}

# ── Language Detection ───────────────────────────────────────────────────────
if (-not $Lang) {
    if ((Test-Path "pyproject.toml") -or (Test-Path "setup.py") -or (Test-Path "requirements.txt")) {
        $Lang = "Python"
    }
    elseif (Test-Path "package.json") {
        $pkg = Get-Content "package.json" -Raw
        if ($pkg -match '"typescript"') { $Lang = "TypeScript" } else { $Lang = "JavaScript" }
    }
    elseif ((Test-Path "pom.xml") -or (Test-Path "build.gradle")) { $Lang = "Java" }
    elseif (Test-Path "go.mod") { $Lang = "Go" }
    elseif (Test-Path "Cargo.toml") { $Lang = "Rust" }
    else { $Lang = "Python" }
}

# ── Framework Detection ──────────────────────────────────────────────────────
$Framework = ""
if (Test-Path "cdk.json") { $Framework = "AWS CDK" }
elseif ((Test-Path "terraform.tf") -or (Test-Path ".terraform") -or (Get-ChildItem *.tf -ErrorAction SilentlyContinue)) { $Framework = "Terraform" }
elseif (Test-Path "serverless.yml") { $Framework = "Serverless Framework" }
elseif ((Test-Path "package.json") -and ((Get-Content "package.json" -Raw) -match '"next"')) { $Framework = "Next.js" }
elseif ((Test-Path "package.json") -and ((Get-Content "package.json" -Raw) -match '"react"')) { $Framework = "React" }

# ── Print results ────────────────────────────────────────────────────────────
Write-Success "Provider: $Provider"
Write-Success "Org: $(if ($Org) { $Org } else { '<not detected>' })"
Write-Success "Repo: $(if ($Repo) { $Repo } else { '<not detected>' })"
Write-Success "Branch: $DefaultBranch"
Write-Success "Lead: $(if ($Lead) { $Lead } else { '<not detected>' })"
Write-Success "Board: $(if ($Board) { $Board } else { '<none>' })"
Write-Success "Language: $Lang"
if ($Framework) { Write-Success "Framework: $Framework" }
Write-Host ""

# ── Interactive fallback ─────────────────────────────────────────────────────
if (-not $Org -or $Interactive) {
    $Org = Read-Host "GitHub org"
}
if (-not $Repo -or $Interactive) {
    $Repo = Read-Host "GitHub repo"
}

# ══════════════════════════════════════════════════════════════════════════════
# GENERATE project-config.md
# ══════════════════════════════════════════════════════════════════════════════

New-Item -ItemType Directory -Force -Path ".kiro\steering" | Out-Null

if ($IsFreshInstall -or -not (Test-Path ".kiro\steering\project-config.md")) {
    $frameworkLine = if ($Framework) { "- **Framework**: $Framework" } else { "" }

    $configContent = @"
---
inclusion: always
---
# Project Configuration

## Project Identity

- **Name**: $ProjectName
- **Default Branch**: $DefaultBranch

## Source Control

- **Provider**: $Provider
- **Org/Owner**: $Org
- **Repo**: $Repo

## Project Tracking

- **Board Provider**: $Provider-projects
- **Board ID**: $(if ($Board) { $Board } else { "none" })

## Team

- **Lead**: $Lead

## Tech Stack

- **Language**: $Lang
$frameworkLine

## AIDLC Preferences

- **Auto-create Issues**: yes
- **Auto-sync Board**: yes

## Installed Powers Registry

| Category | Power Name | Activate During |
|----------|-----------|------------------|

"@
    Set-Content -Path ".kiro\steering\project-config.md" -Value $configContent
    Write-Success "Generated .kiro\steering\project-config.md"
}
else {
    Write-Info "Keeping existing .kiro\steering\project-config.md (upgrade mode)"
}

# ══════════════════════════════════════════════════════════════════════════════
# CREATE FOLDER STRUCTURE + INSTALL FILES
# ══════════════════════════════════════════════════════════════════════════════

$folders = @(
    ".kiro\hooks",
    ".kiro\aws-aidlc-rule-details\common",
    ".kiro\aws-aidlc-rule-details\inception",
    ".kiro\aws-aidlc-rule-details\construction",
    ".kiro\aws-aidlc-rule-details\operations",
    ".kiro\aws-aidlc-rule-details\extensions",
    "aidlc-docs\inception\user-stories",
    "aidlc-docs\construction\build-and-test",
    "aidlc-docs\archive",
    "aidlc-docs\cycles"
)

foreach ($dir in $folders) {
    New-Item -ItemType Directory -Force -Path $dir | Out-Null
}
Write-Success "Created folder structure"

# ── Steering files ───────────────────────────────────────────────────────────
if ($PowerDir -and (Test-Path "$PowerDir\steering")) {
    $IsUpgrade = -not $IsFreshInstall
    Get-ChildItem "$PowerDir\steering\*.md" | ForEach-Object {
        if ($_.Name -eq "project-config-template.md") { return }
        $target = ".kiro\steering\$($_.Name)"

        if ($IsUpgrade -and (Test-Path $target)) {
            $diff = Compare-Object (Get-Content $_.FullName) (Get-Content $target) -ErrorAction SilentlyContinue
            if ($diff) {
                Copy-Item $target "$target.bak"
                Copy-Item $_.FullName $target
                Write-Info "Updated $($_.Name) (backup: $($_.Name).bak)"
            }
        }
        else {
            Copy-Item $_.FullName $target
        }
    }
    Write-Success "Installed steering files"
}

# ── Workflow rule-details ────────────────────────────────────────────────────
if ($PowerDir -and (Test-Path "$PowerDir\workflows")) {
    Copy-Item "$PowerDir\workflows\common\*.md" ".kiro\aws-aidlc-rule-details\common\" -ErrorAction SilentlyContinue
    Copy-Item "$PowerDir\workflows\inception\*.md" ".kiro\aws-aidlc-rule-details\inception\" -ErrorAction SilentlyContinue
    Copy-Item "$PowerDir\workflows\construction\*.md" ".kiro\aws-aidlc-rule-details\construction\" -ErrorAction SilentlyContinue
    Copy-Item "$PowerDir\workflows\operations\*.md" ".kiro\aws-aidlc-rule-details\operations\" -ErrorAction SilentlyContinue
    if (Test-Path "$PowerDir\workflows\extensions") {
        Copy-Item "$PowerDir\workflows\extensions\*" ".kiro\aws-aidlc-rule-details\extensions\" -Recurse -ErrorAction SilentlyContinue
    }
    Write-Success "Installed workflow rules"
}

# ── Hooks ────────────────────────────────────────────────────────────────────
if ($PowerDir -and (Test-Path "$PowerDir\hooks")) {
    $IsUpgrade = -not $IsFreshInstall
    Get-ChildItem "$PowerDir\hooks\*.json" | ForEach-Object {
        $target = ".kiro\hooks\$($_.Name)"
        if ($IsUpgrade -and (Test-Path $target)) {
            $diff = Compare-Object (Get-Content $_.FullName) (Get-Content $target) -ErrorAction SilentlyContinue
            if ($diff) {
                Copy-Item $target "$target.bak"
                Copy-Item $_.FullName $target
                Write-Info "Updated hook $($_.Name) (backup: $($_.Name).bak)"
            }
        }
        else {
            Copy-Item $_.FullName $target
        }
    }
    Write-Success "Installed hooks"
}

# ── AIDLC state ─────────────────────────────────────────────────────────────
if (-not (Test-Path "aidlc-docs\aidlc-state.md")) {
    $stateContent = @"
# AIDLC State
- **Phase**: Not Started
- **Stage**: N/A
- **AIDLC Version**: $AIDLC_POWER_VERSION
"@
    Set-Content -Path "aidlc-docs\aidlc-state.md" -Value $stateContent
}

# ── Audit log ────────────────────────────────────────────────────────────────
if (-not (Test-Path "aidlc-docs\audit.md")) {
    Set-Content -Path "aidlc-docs\audit.md" -Value "# AIDLC Audit Log"
}

# ── Write version file ───────────────────────────────────────────────────────
Set-Content -Path ".aidlc-version" -Value $AIDLC_POWER_VERSION
Write-Success "Version recorded: v$AIDLC_POWER_VERSION"

# ── Update state version on upgrade ─────────────────────────────────────────
if (-not $IsFreshInstall) {
    $content = Get-Content "aidlc-docs\aidlc-state.md" -Raw
    $content = $content -replace "AIDLC Version: .*", "AIDLC Version: $AIDLC_POWER_VERSION"
    Set-Content -Path "aidlc-docs\aidlc-state.md" -Value $content
}

# ══════════════════════════════════════════════════════════════════════════════
# GPG SIGNING CHECK
# ══════════════════════════════════════════════════════════════════════════════

Write-Host ""
$signingKey = git config --get user.signingkey 2>$null
$gpgSign = git config --get commit.gpgsign 2>$null

if (-not $signingKey -or $gpgSign -ne "true") {
    Write-Warn "GPG commit signing is not configured."
    Write-Host "  AIDLC requires signed commits. Run these commands:" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  gpg --full-generate-key" -ForegroundColor Cyan
    Write-Host "  gpg --list-secret-keys --keyid-format=long" -ForegroundColor Cyan
    Write-Host "  git config --global user.signingkey <YOUR_KEY_ID>" -ForegroundColor Cyan
    Write-Host "  git config --global commit.gpgsign true" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  SSH signing also supported: set gpg.format=ssh and point user.signingkey to your key." -ForegroundColor DarkGray
    Write-Host ""
}
else {
    Write-Success "GPG signing configured (key: $($signingKey.Substring(0, [Math]::Min(8, $signingKey.Length)))...)"
}

# ══════════════════════════════════════════════════════════════════════════════
# DONE
# ══════════════════════════════════════════════════════════════════════════════

Write-Host ""
if (-not $IsFreshInstall) {
    Write-Host "  Upgrade complete! v$InstalledVersion -> v$AIDLC_POWER_VERSION" -ForegroundColor Green
}
else {
    Write-Host "  Done! AIDLC configured for $Org/$Repo ($Provider)" -ForegroundColor Green
}
Write-Host ""
Write-Host "  To start: " -NoNewline; Write-Host '"Using AI-DLC, build me ..."' -ForegroundColor Green
Write-Host "  To customize: edit " -NoNewline; Write-Host ".kiro\steering\project-config.md" -ForegroundColor Cyan
Write-Host ""

# ── Post-setup hints ─────────────────────────────────────────────────────────
if (-not $Board -or $Board -eq "none") {
    Write-Host "  -> No project board detected. Update Board ID in .kiro\steering\project-config.md" -ForegroundColor Yellow
}
if (-not $Lead) {
    Write-Host "  -> No team lead detected. Update Team > Lead in project-config.md" -ForegroundColor Yellow
}
if (-not $Framework) {
    Write-Host "  -> No framework detected. Add Framework in project-config.md if applicable" -ForegroundColor Yellow
}
Write-Host ""
