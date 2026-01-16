# Agent-Friendly Release Documentation

This document provides structured, step-by-step instructions for AI agents to manage releases in the skills-workshop repository. It complements the human-focused documentation in `README.md`.

## Table of Contents

1. [Quick Reference](#quick-reference)
2. [Semantic Versioning Decision Tree](#semantic-versioning-decision-tree)
3. [Release Process - Step-by-Step](#release-process---step-by-step)
4. [Validation Checklist](#validation-checklist)
5. [File Locations Reference](#file-locations-reference)
6. [Common Scenarios with Examples](#common-scenarios-with-examples)
7. [Safety Guardrails](#safety-guardrails)

---

## Quick Reference

### Version Number Format
- Pattern: `MAJOR.MINOR.PATCH`
- Example: `2.0.1`
- Regex validation: `^\d+\.\d+\.\d+$`

### Essential Commands

```bash
# Check current version
cat releases/git-worktree-tool/VERSION

# Display version from script
git-worktree-tool/wt --version

# View recent commits
git log --oneline -10

# List tags for skill
git tag -l "git-worktree-tool/*"

# Check git status before release
git status

# Verify working directory is clean
git status --porcelain
```

### File Locations (git-worktree-tool)

| Location | Purpose | Pattern |
|----------|---------|---------|
| `git-worktree-tool/wt` | Embedded version | `VERSION="X.Y.Z"` |
| `releases/git-worktree-tool/VERSION` | Version source-of-truth | Single line: `X.Y.Z` |
| `releases/git-worktree-tool/CHANGELOG.md` | Release history | Keep a Changelog format |
| `git-worktree-tool/SKILL.md` | Documentation version | Marked in version section |

---

## Semantic Versioning Decision Tree

Use this decision tree to determine which version number to bump:

```
START: Analyze changes since last release
│
├─ ANY breaking changes detected?
│  │  (Changed function signatures, removed parameters, behavior changes)
│  │
│  └─ YES → BUMP MAJOR VERSION (X.0.0)
│     │    Examples:
│     │    - Removed --force flag completely
│     │    - Changed return value format
│     │    - Removed subcommand
│     │
│     └─ MAJOR bump complete
│
├─ NEW features or functionality added?
│  │  (New subcommands, new options, new capabilities)
│  │
│  └─ YES → BUMP MINOR VERSION (0.X.0)
│     │    Examples:
│     │    - Added wt config subcommand
│     │    - Added --skip-checks flag
│     │    - Added configuration file support
│     │
│     └─ MINOR bump complete
│
├─ ONLY bug fixes or improvements?
│  │  (Fixed logic errors, improved performance, better messages)
│  │
│  └─ YES → BUMP PATCH VERSION (0.0.X)
│     │    Examples:
│     │    - Fixed output formatting
│     │    - Improved error messages
│     │    - Fixed edge case in branch handling
│     │
│     └─ PATCH bump complete
│
└─ UNCERTAIN?
   └─ DO NOT PROCEED - Ask user for clarification
```

### Decision Tree Examples

**Example 1: Should this be MAJOR?**
```
Change: Removed --force flag, changed behavior to always prompt
Decision: YES, this is breaking → MAJOR bump (2.0.0 → 3.0.0)
```

**Example 2: Should this be MINOR?**
```
Change: Added new wt config subcommand with backward compatible options
Decision: YES, new feature but backward compatible → MINOR bump (2.0.0 → 2.1.0)
```

**Example 3: Should this be PATCH?**
```
Change: Fixed bug in wt list output formatting
Decision: YES, bug fix only → PATCH bump (2.0.0 → 2.0.1)
```

---

## Release Process - Step-by-Step

Follow these steps in order. Each step must complete successfully before proceeding to the next.

### Pre-Release Verification

Before starting the release process, verify these conditions:

**Step 0a: Verify Clean Working Directory**
```bash
git status --porcelain
# Output should be empty (no untracked or modified files)
```

**Step 0b: Verify Current Branch**
```bash
git rev-parse --abbrev-ref HEAD
# Should show: release-documentation or main (depending on where release is happening)
```

**Step 0c: Verify Current Version**
```bash
cat releases/git-worktree-tool/VERSION
# Should show current version (e.g., 2.0.0)
```

**If any check fails:** Do not proceed. Resolve the issue before starting release process.

---

### Release Steps

#### Step 1: Determine New Version

**Input:** Current version and change type (MAJOR, MINOR, or PATCH)

**Process:**

1. Read current version:
   ```bash
   CURRENT_VERSION=$(cat releases/git-worktree-tool/VERSION)
   echo "Current version: $CURRENT_VERSION"
   ```

2. Parse version components (if MAJOR.MINOR.PATCH is "2.0.0"):
   - MAJOR = 2
   - MINOR = 0
   - PATCH = 0

3. Apply semantic versioning rule:
   ```
   IF change_type == "MAJOR"
     NEW_VERSION = (MAJOR+1).0.0
   ELSE IF change_type == "MINOR"
     NEW_VERSION = MAJOR.(MINOR+1).0
   ELSE IF change_type == "PATCH"
     NEW_VERSION = MAJOR.MINOR.(PATCH+1)
   ```

4. Example calculations:
   - Current: 2.0.0, PATCH bump → New: 2.0.1
   - Current: 2.0.1, MINOR bump → New: 2.1.0
   - Current: 2.1.0, MAJOR bump → New: 3.0.0

**Output:** `NEW_VERSION` variable set correctly

---

#### Step 2: Update Embedded Version in Script

**Input:** `NEW_VERSION` (e.g., "2.0.1")

**Process:**

1. Locate the VERSION line in the script:
   ```bash
   grep -n "VERSION=" git-worktree-tool/wt | head -1
   # Expected output: 16:VERSION="2.0.0"
   ```

2. Update the version (replace old version with new):
   ```bash
   sed -i '' "s/VERSION=\"[0-9]*\.[0-9]*\.[0-9]*\"/VERSION=\"$NEW_VERSION\"/" git-worktree-tool/wt
   ```

3. Verify the change:
   ```bash
   grep "VERSION=" git-worktree-tool/wt | head -1
   # Should show: VERSION="2.0.1"
   ```

**Output:** Script file updated with new version

**Verification:** Run `git-worktree-tool/wt --version` → should display new version

---

#### Step 3: Update VERSION File

**Input:** `NEW_VERSION` (e.g., "2.0.1")

**Process:**

1. Write new version to file (single line, no trailing whitespace):
   ```bash
   echo "$NEW_VERSION" > releases/git-worktree-tool/VERSION
   ```

2. Verify the file:
   ```bash
   cat releases/git-worktree-tool/VERSION
   # Should show: 2.0.1
   ```

3. Verify no extra whitespace:
   ```bash
   wc -l releases/git-worktree-tool/VERSION
   # Should show: 1 (exactly one line)
   ```

**Output:** VERSION file updated and verified

---

#### Step 4: Update CHANGELOG.md

**Input:**
- `NEW_VERSION` (e.g., "2.0.1")
- Today's date in `YYYY-MM-DD` format
- List of changes (Added, Changed, Fixed, Breaking sections as applicable)

**Process:**

1. Determine today's date:
   ```bash
   TODAY=$(date +%Y-%m-%d)
   echo $TODAY  # Should show: 2026-01-16 (example)
   ```

2. Open `releases/git-worktree-tool/CHANGELOG.md`

3. Find the first `##` header (after the main header)

4. Insert new version section at the top (after the main header, before any existing version entries)

5. Use this format:
   ```markdown
   ## [X.Y.Z] - YYYY-MM-DD

   ### Added
   - New feature description

   ### Changed
   - Changed feature description

   ### Fixed
   - Fixed bug description

   ### Breaking
   - Breaking change description (if MAJOR bump)
   ```

6. Follow **Keep a Changelog** format rules:
   - Each change is a bulleted list item
   - Sections are optional (only include relevant sections)
   - Links to commits should use format `[#123](url)` if available
   - Keep entries concise but descriptive

**Example (Patch Release):**
```markdown
## [2.0.1] - 2026-01-17

### Fixed
- Fixed output formatting in `wt list` command to properly align columns
- Fixed edge case where worktree status could show stale information
```

**Example (Minor Release):**
```markdown
## [2.1.0] - 2026-01-18

### Added
- New `wt config` subcommand for managing user configuration
- Configuration file support at `~/.config/wt/config`
- New `--skip-checks` flag to bypass pre-flight validation

### Changed
- Improved error messages for better clarity
```

**Example (Major Release):**
```markdown
## [3.0.0] - 2026-01-19

### Breaking
- Removed `--force` flag (use `--skip-checks` instead)
- Changed default behavior to always prompt before deletion
- Repository structure now requires `releases/` directory

### Added
- New `--skip-checks` flag as safer alternative to removed `--force`
- Configuration system for customizing default behavior

### Changed
- Improved error messages and user feedback
- Refactored worktree status detection for better accuracy
```

**Output:** CHANGELOG.md updated with new version section

---

#### Step 5: Update Skill Documentation (if applicable)

**Input:** `NEW_VERSION` (e.g., "2.0.1")

**Process:**

1. Open `git-worktree-tool/SKILL.md`

2. Search for version mention (typically in an info section at top or introduction)

3. Find pattern: `- **Version**: X.Y.Z` or similar

4. Update to new version:
   ```
   - **Version**: 2.0.1
   ```

5. Verify the update:
   ```bash
   grep -n "Version" git-worktree-tool/SKILL.md | head -3
   ```

**Output:** Documentation version updated

---

#### Step 6: Commit Changes

**Input:**
- All modified files staged
- Skill name: "git-worktree-tool"
- New version: "2.0.1"

**Process:**

1. Verify changed files:
   ```bash
   git status
   # Should show modified: git-worktree-tool/wt, releases/git-worktree-tool/VERSION, etc.
   ```

2. Stage all release-related changes:
   ```bash
   git add git-worktree-tool/wt \
           releases/git-worktree-tool/VERSION \
           releases/git-worktree-tool/CHANGELOG.md \
           git-worktree-tool/SKILL.md  # if updated
   ```

3. Verify staged changes:
   ```bash
   git status --short
   # Should show M (modified) for the files above
   ```

4. Create commit with standard format:
   ```bash
   git commit -m "Bump git-worktree-tool to v2.0.1"
   ```

5. Verify commit created:
   ```bash
   git log --oneline -1
   # Should show: abc1234 Bump git-worktree-tool to v2.0.1
   ```

**Commit Message Format:**
```
Bump <skill-name> to v<VERSION>
```

Examples:
- `Bump git-worktree-tool to v2.0.1`
- `Bump git-worktree-tool to v2.1.0`
- `Bump git-worktree-tool to v3.0.0`

**Output:** Commit created and ready for tagging

---

#### Step 7: Create Git Tag

**Input:**
- Skill name: "git-worktree-tool"
- New version: "2.0.1"

**Process:**

1. Create annotated tag (includes commit message):
   ```bash
   git tag -a "git-worktree-tool/v2.0.1" -m "Release git-worktree-tool v2.0.1"
   ```

2. Verify tag created:
   ```bash
   git tag -l "git-worktree-tool/*"
   # Should list: git-worktree-tool/v2.0.1
   ```

3. Verify tag points to correct commit:
   ```bash
   git show "git-worktree-tool/v2.0.1" | head -5
   # Should show commit message and details
   ```

**Tag Format:**
```
<skill-name>/v<VERSION>
```

Examples:
- `git-worktree-tool/v2.0.1`
- `git-worktree-tool/v2.1.0`
- `git-worktree-tool/v3.0.0`

**Important:** Tags are permanent. Verify everything is correct before creating tags.

**Output:** Git tag created and verified

---

#### Step 8: Push Changes and Tags

**Input:** New commit and tag ready to push

**Process:**

1. Verify nothing else will be pushed:
   ```bash
   git status
   # Should show: "Your branch is ahead of 'origin/...' by 1 commit"
   ```

2. Push commit:
   ```bash
   git push origin HEAD
   # Or: git push origin release-documentation (if on release-documentation branch)
   ```

3. Verify commit pushed:
   ```bash
   git log origin/HEAD -1
   # Should show the commit you just pushed
   ```

4. Push tag:
   ```bash
   git push origin "git-worktree-tool/v2.0.1"
   ```

5. Verify tag pushed:
   ```bash
   git tag -l -r "origin/git-worktree-tool/*"
   # Should list: origin/git-worktree-tool/v2.0.1
   ```

**Output:** Commit and tag pushed to remote

---

### Post-Release Validation

After pushing, perform these verification steps:

**Validation 1: Verify Version Consistency**
```bash
# All should show same version (e.g., 2.0.1)
cat releases/git-worktree-tool/VERSION
grep "VERSION=" git-worktree-tool/wt | head -1
git-worktree-tool/wt --version
```

**Validation 2: Verify Git Tag**
```bash
# Should list the new tag
git tag -l "git-worktree-tool/*" | tail -3

# Should show tag exists on remote
git ls-remote --tags origin | grep "git-worktree-tool/v2.0.1"
```

**Validation 3: Verify CHANGELOG Entry**
```bash
# Should show new version at top
head -20 releases/git-worktree-tool/CHANGELOG.md
```

**Validation 4: Test Version Command**
```bash
# Should display new version
git-worktree-tool/wt --version
```

---

## Validation Checklist

**Use this checklist before committing to verify release is correct:**

```
Pre-Commit Validation:
[ ] Current version numbers verified (all locations match)
[ ] New version follows semantic versioning pattern (X.Y.Z)
[ ] New version correctly determined using decision tree
[ ] CHANGELOG.md has new version section with proper date
[ ] CHANGELOG.md sections use correct Keep a Changelog format
[ ] CHANGELOG.md entries are clear and descriptive
[ ] All file locations updated:
    [ ] Embedded version in git-worktree-tool/wt updated
    [ ] releases/git-worktree-tool/VERSION updated
    [ ] releases/git-worktree-tool/CHANGELOG.md updated
    [ ] git-worktree-tool/SKILL.md updated (if applicable)
[ ] No unrelated files modified in this release
[ ] No uncommitted changes in working directory
[ ] Commit message follows format: "Bump <skill-name> to v<VERSION>"
[ ] Git tag follows format: "<skill-name>/v<VERSION>"
[ ] Working directory will be clean after commit

Post-Commit Validation:
[ ] Commit created successfully
[ ] Tag created successfully
[ ] git log shows new commit
[ ] git tag -l shows new tag
[ ] Version command displays new version: git-worktree-tool/wt --version
[ ] All version numbers still consistent across locations
```

---

## File Locations Reference

### git-worktree-tool Skill

| File | Location | Pattern | Search |
|------|----------|---------|--------|
| Embedded Version | `git-worktree-tool/wt` | `VERSION="X.Y.Z"` | Line 16 |
| Version Source | `releases/git-worktree-tool/VERSION` | Single line: `X.Y.Z` | Full file |
| Release History | `releases/git-worktree-tool/CHANGELOG.md` | Keep a Changelog format | Header: `## [X.Y.Z]` |
| Documentation | `git-worktree-tool/SKILL.md` | `- **Version**: X.Y.Z` | Search for "Version:" |

### How to Find Version Locations

**Find all version mentions (agent diagnostic):**
```bash
grep -r "2\.0\.0" --include="*.md" --include="wt" . 2>/dev/null || true
# Lists all files mentioning current version
```

**Find only the key version files:**
```bash
echo "=== Embedded Version ==="
grep "VERSION=" git-worktree-tool/wt | head -1
echo "=== File Version ==="
cat releases/git-worktree-tool/VERSION
echo "=== Changelog Version ==="
grep "^## \[" releases/git-worktree-tool/CHANGELOG.md | head -1
```

---

## Common Scenarios with Examples

### Scenario 1: Patch Release (Bug Fix)

**Trigger:** Bug fix with no API changes

**Current State:**
```
Version: 2.0.0
Change: Fixed output formatting in wt list command
Change type: PATCH (bug fix only)
```

**Step 1 - Determine Version:**
- Current: 2.0.0
- Change type: PATCH
- New version: 2.0.1

**Step 2-5 - Update Files:**

```bash
# Update embedded version
sed -i '' 's/VERSION="2.0.0"/VERSION="2.0.1"/' git-worktree-tool/wt

# Update VERSION file
echo "2.0.1" > releases/git-worktree-tool/VERSION

# Update CHANGELOG.md - add at top
cat >> temp.md << 'EOF'
## [2.0.1] - 2026-01-17

### Fixed
- Fixed output formatting in `wt list` command to properly align columns
- Fixed edge case where worktree status could show stale information

EOF
cat releases/git-worktree-tool/CHANGELOG.md >> temp.md
mv temp.md releases/git-worktree-tool/CHANGELOG.md

# Update documentation version
sed -i '' 's/- \*\*Version\*\*: 2.0.0/- **Version**: 2.0.1/' git-worktree-tool/SKILL.md
```

**Step 6 - Commit:**
```bash
git add git-worktree-tool/wt releases/git-worktree-tool/VERSION releases/git-worktree-tool/CHANGELOG.md git-worktree-tool/SKILL.md
git commit -m "Bump git-worktree-tool to v2.0.1"
```

**Step 7 - Tag:**
```bash
git tag -a "git-worktree-tool/v2.0.1" -m "Release git-worktree-tool v2.0.1"
```

**Step 8 - Push:**
```bash
git push origin HEAD
git push origin "git-worktree-tool/v2.0.1"
```

---

### Scenario 2: Minor Release (New Feature)

**Trigger:** New feature, backward compatible

**Current State:**
```
Version: 2.0.1
Change: Added wt config subcommand for managing configuration
Change type: MINOR (new feature)
```

**New Version Calculation:**
- Current: 2.0.1
- Change type: MINOR
- New version: 2.1.0

**CHANGELOG Entry:**
```markdown
## [2.1.0] - 2026-01-18

### Added
- New `wt config` subcommand for managing user configuration
- Configuration file support at `~/.config/wt/config`
- New `--list` flag to list all worktrees with advanced filtering

### Changed
- Improved error messages for better clarity and actionability
```

**Process:**
1. Update `git-worktree-tool/wt`: VERSION="2.0.1" → VERSION="2.1.0"
2. Update `releases/git-worktree-tool/VERSION`: 2.0.1 → 2.1.0
3. Add section to `releases/git-worktree-tool/CHANGELOG.md`
4. Update `git-worktree-tool/SKILL.md` version
5. Commit: "Bump git-worktree-tool to v2.1.0"
6. Tag: "git-worktree-tool/v2.1.0"
7. Push both commit and tag

---

### Scenario 3: Major Release (Breaking Change)

**Trigger:** Breaking change to API or behavior

**Current State:**
```
Version: 2.1.0
Change: Removed --force flag, changed behavior to always prompt
Change type: MAJOR (breaking change)
```

**New Version Calculation:**
- Current: 2.1.0
- Change type: MAJOR
- New version: 3.0.0

**CHANGELOG Entry:**
```markdown
## [3.0.0] - 2026-01-19

### Breaking
- Removed `--force` flag (use `--skip-checks` instead for safer deletion)
- Changed default behavior to always prompt before deleting worktrees
- Updated configuration file format (migration guide below)

### Added
- New `--skip-checks` flag as safer alternative to removed `--force`
- New `--no-prompt` flag for automation (requires `--skip-checks`)
- Configuration system for customizing default behavior

### Changed
- Improved error messages and user feedback
- Refactored worktree status detection for better accuracy
- Updated documentation with migration examples

### Migration Guide for Users

**From 2.x to 3.0:**

Old command:
```bash
wt delete my-branch --force
```

New command:
```bash
wt delete my-branch --skip-checks
```

Or use the safer approach with prompt:
```bash
wt delete my-branch
# Will prompt before deletion
```
```

**Process:**
1. Update all version locations to 3.0.0
2. Comprehensive CHANGELOG with breaking section and migration guide
3. Update all documentation versions
4. Commit: "Bump git-worktree-tool to v3.0.0"
5. Tag: "git-worktree-tool/v3.0.0"
6. Push

---

## Safety Guardrails

### Actions NEVER to Take

**❌ Version Management**
- Never bump version without understanding what changed
- Never skip CHANGELOG.md updates
- Never create mismatched versions (different values in different files)
- Never force push to main/master branches
- Never delete or modify existing version tags
- Never bump MAJOR version without explicit human confirmation

**❌ File Operations**
- Never commit version changes with other unrelated code changes
- Never modify released files (only VERSION, CHANGELOG, embedded version, docs)
- Never change git history (rebase, amend) on released commits

**❌ Process Violations**
- Never skip pre-commit validation checks
- Never push without verifying working directory is clean
- Never tag before commit is finalized
- Never push to remote without local verification

---

### Actions ALWAYS to Take

**✅ Verification**
- Always verify version consistency across ALL locations before committing
- Always follow semantic versioning rules strictly
- Always include descriptive CHANGELOG entries
- Always test version display after changes: `git-worktree-tool/wt --version`
- Always confirm working directory is clean before starting

**✅ Communication**
- Always provide clear reasoning for version bump decision
- Always include migration guides for MAJOR version breaks
- Always make commit messages descriptive and consistent

**✅ Safety Checks**
- Always run validation checklist before committing
- Always verify tag format matches requirements
- Always check that remote has tag before assuming success

---

### When to Ask for Human Confirmation

**⏸️ Ask Before Proceeding:**

1. **MAJOR Version Bumps** - Always ask human before bumping MAJOR
   ```
   "I've identified breaking changes. This requires a MAJOR version bump.
    Current: 2.1.0 → New: 3.0.0
    Changes: [list breaking changes]
    Should I proceed?"
   ```

2. **Ambiguous Change Types** - If unsure between MINOR and PATCH
   ```
   "Change: [describe change]
    This could be MINOR (new capability) or PATCH (improvement).
    Which should it be?"
   ```

3. **Unclear CHANGELOG Entries** - If change description is ambiguous
   ```
   "I'm unsure how to describe this change in the CHANGELOG.
    Change summary: [description]
    Should I categorize this as [option 1] or [option 2]?"
   ```

4. **Before Pushing to Remote** - Always ask before final push
   ```
   "Ready to push. This will create:
    - Commit: Bump git-worktree-tool to v2.0.1
    - Tag: git-worktree-tool/v2.0.1
    Should I proceed?"
   ```

---

## Troubleshooting

### Version Mismatch Detected

**Problem:** Different version numbers in different files

**Detection:**
```bash
echo "=== Versions Found ==="
echo "Embedded: $(grep VERSION= git-worktree-tool/wt | head -1 | sed 's/.*VERSION="\([^"]*\)".*/\1/')"
echo "File: $(cat releases/git-worktree-tool/VERSION)"
echo "Changelog: $(grep '## \[' releases/git-worktree-tool/CHANGELOG.md | head -1 | sed 's/.*\[\([^]]*\)\].*/\1/')"
# These three should all match
```

**Resolution:**
1. Identify the correct version (what should it be?)
2. Update all three locations to match
3. Commit with message: "Fix: correct version mismatch to vX.Y.Z"

---

### Tag Already Exists

**Problem:** Attempted to create tag that already exists

**Detection:**
```bash
git tag -l "git-worktree-tool/v2.0.1"
# If returns a result, tag exists
```

**Resolution:**
- If tag points to wrong commit: Contact repository maintainer (don't delete tags)
- If version already released: Increment version and create new tag

---

### Uncommitted Changes

**Problem:** Working directory has uncommitted changes

**Detection:**
```bash
git status --porcelain
# If output is not empty, changes exist
```

**Resolution:**
1. Save your work: `git stash`
2. Verify working directory is clean: `git status`
3. Start release process

---

## Integration with CI/CD

This release process is designed to work with automated workflows. Key integration points:

**Pre-Release Automation:**
- Script can verify version consistency
- Script can validate CHANGELOG format
- Script can run tests before allowing release

**Post-Release Automation:**
- Webhook can trigger on tag push
- Artifact building on tag creation
- Release notes generation from CHANGELOG

**GitHub Actions Example:**
```yaml
name: Release on Tag
on:
  push:
    tags:
      - 'git-worktree-tool/v*'
jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Create Release
        run: |
          version=$(cat releases/git-worktree-tool/VERSION)
          # Create GitHub release from CHANGELOG
```

---

## Additional Resources

- **Main Documentation:** See `README.md` for human-friendly overview
- **Skill Guide:** See `git-worktree-tool/SKILL.md` for feature details
- **Keep a Changelog:** https://keepachangelog.com/
- **Semantic Versioning:** https://semver.org/
- **Git Tagging:** https://git-scm.com/docs/git-tag

