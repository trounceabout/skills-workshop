# Claude Code Release Instructions

This document provides Claude Code-specific guidance for handling release requests. It complements the comprehensive process documentation in `docs/RELEASES.md`.

## Overview

When users ask Claude Code to "cut a release", "bump version", or "create a new release", follow this structured approach:

1. **Understand what changed**
2. **Determine the version bump type**
3. **Follow the step-by-step process in docs/RELEASES.md**
4. **Ask for confirmation before pushing**

---

## Step 1: Understand What Changed

When a user requests a release, first clarify what was actually changed:

### Questions to Ask

**If the user is vague:**
```
"Before bumping the version, I need to understand what changed:
1. What features or fixes were added/changed since the last release?
2. Are there any breaking changes to the API or behavior?
3. Is this a bug fix, new feature, or breaking change?"
```

**If the user provides context:**
- Review recent commits: `git log <last-tag>..HEAD --oneline`
- Check changed files: `git diff <last-tag>..HEAD --name-only`
- Read the commit messages to understand scope

**Example:**
```bash
# If last tag was git-worktree-tool/v2.0.0
git log git-worktree-tool/v2.0.0..HEAD --oneline
# This shows all commits since the last release
```

---

## Step 2: Determine Version Bump Type

Use this decision tree to categorize the change:

### Decision Tree

```
User says: "I added a new config subcommand"
└─ Is this a new capability? YES
   └─ Is it backward compatible? YES
   └─ Decision: MINOR bump (new feature)

User says: "I fixed the output formatting bug"
└─ Is this a new capability? NO
   └─ Is this a bug fix only? YES
   └─ Decision: PATCH bump

User says: "I removed the --force flag"
└─ Is this breaking existing code? YES
   └─ Decision: MAJOR bump (breaking change)
```

### Mapping User Language to Version Type

| User Says | Actual Type | Decision |
|-----------|------------|----------|
| "bug fix" | Bug fix only | PATCH |
| "new feature" | New backward-compatible capability | MINOR |
| "breaking change" | API or behavior changed | MAJOR |
| "improvement" | Better error messages, performance | PATCH |
| "new command" | New subcommand or flag | MINOR |
| "removed..." | Removed feature or changed behavior | MAJOR |
| "refactored" | Internal changes only | PATCH |

### When to Ask for Clarification

**Ask if:**
- User is ambiguous about whether change is MINOR or PATCH
- Change could be interpreted multiple ways
- You're unsure if something is truly breaking

**Example:**
```
"Change: Added optional parameter to existing function
This could be:
- MINOR (new feature) if old code still works unchanged
- PATCH (improvement) if it's just an internal enhancement

Is this backward compatible? (Can existing code run unchanged?)"
```

---

## Step 3: Version Calculation

Once you know the change type, calculate the new version:

### Calculate New Version

**From current version (get from `releases/git-worktree-tool/VERSION`):**

```
Current Version: 2.0.0 (means MAJOR=2, MINOR=0, PATCH=0)

IF change type = MAJOR
  New Version = (MAJOR+1).0.0 = 3.0.0

IF change type = MINOR
  New Version = MAJOR.(MINOR+1).0 = 2.1.0

IF change type = PATCH
  New Version = MAJOR.MINOR.(PATCH+1) = 2.0.1
```

### Examples

```
Current: 2.0.0, Type: PATCH → New: 2.0.1
Current: 2.0.1, Type: MINOR → New: 2.1.0
Current: 2.1.0, Type: MAJOR → New: 3.0.0
```

---

## Step 4: Follow docs/RELEASES.md Process

Once version is determined, follow the step-by-step process in `docs/RELEASES.md`:

1. **Step 1:** Determine New Version ✓ (done above)
2. **Step 2:** Update embedded version in script
3. **Step 3:** Update VERSION file
4. **Step 4:** Update CHANGELOG.md
5. **Step 5:** Update documentation version (if applicable)
6. **Step 6:** Commit changes
7. **Step 7:** Create git tag
8. **Step 8:** Push changes (after user confirmation)

**For detailed instructions on each step, refer to `docs/RELEASES.md`.**

---

## Step 5: Ask User Confirmation Before Pushing

**ALWAYS ask before pushing to remote:**

```
"I've prepared the release:
- Current version: 2.0.0
- New version: 2.0.1
- Change type: PATCH (bug fix)
- Changes made:
  1. Updated git-worktree-tool/wt (VERSION variable)
  2. Updated releases/git-worktree-tool/VERSION
  3. Added CHANGELOG entry for v2.0.1
  4. Updated git-worktree-tool/SKILL.md

Verification complete:
✓ All versions consistent
✓ CHANGELOG follows Keep a Changelog format
✓ Working directory clean
✓ Commit message: 'Bump git-worktree-tool to v2.0.1'
✓ Tag format: 'git-worktree-tool/v2.0.1'

Ready to push? This will:
- Push commit: Bump git-worktree-tool to v2.0.1
- Create tag: git-worktree-tool/v2.0.1
- Push tag to remote"
```

---

## Common User Requests and Responses

### Request 1: "Bump to v2.1.0"

**User Action:** Specifying exact version

**Claude Response:**
```
"User specified exact version: 2.1.0
Current version: 2.0.0
This is a MINOR version bump.

Is this for a new feature that's backward compatible?"
```

**If yes:** Proceed with MINOR release process
**If no:** Ask to clarify what type of change this is

---

### Request 2: "Cut a patch release"

**User Action:** Specifying release type explicitly

**Claude Response:**
```
"Cutting a patch release.
Current version: 2.0.0
New version: 2.0.1

This is for bug fixes with no new features.
What changes should I include in the CHANGELOG?"
```

---

### Request 3: "Release the new config feature"

**User Action:** Describing feature addition

**Claude Response:**
```
"New config feature added - this is a MINOR release.
Current version: 2.0.0
New version: 2.1.0

Can you provide a brief description of the new config feature for the CHANGELOG?
(For example: 'Added wt config subcommand for managing user configuration')"
```

---

### Request 4: "Fix the bug and release"

**User Action:** Bug fix request

**Claude Response:**
```
"I'll create a patch release for the bug fix.
Current version: 2.0.0
New version: 2.0.1

Can you describe the bug that was fixed?
(For the CHANGELOG, e.g., 'Fixed output formatting in wt list command')"
```

---

### Request 5: "Breaking change - major release"

**User Action:** Explicit breaking change

**Claude Response:**
```
⚠️ MAJOR VERSION BUMP ALERT

Breaking changes detected!
Current version: 2.1.0
New version: 3.0.0

Breaking changes should be clearly documented:
- What was removed or changed?
- What should users do to migrate?
- Are there alternatives to the removed feature?

Please confirm this is intentional and provide details for the CHANGELOG."
```

---

## Workflow Example

Here's a complete example workflow:

### User Request
```
"Release the git-worktree-tool v2.0.1 with the bug fixes"
```

### Claude Step 1: Clarify
```
"I'll create a patch release for the bug fixes.
Just to confirm - these are bug fixes only with no new features, correct?
Can you describe what was fixed so I can update the CHANGELOG?"
```

### User Response
```
"Yes, just bug fixes. We fixed the output formatting in 'wt list' and
fixed an edge case with worktree status detection."
```

### Claude Step 2: Calculate Version
```
"Perfect. Current version: 2.0.0
Change type: PATCH (bug fixes only)
New version: 2.0.1"
```

### Claude Step 3: Execute Release
- Update all 4 version locations
- Add CHANGELOG entry for v2.0.1 with the two fixes
- Commit: "Bump git-worktree-tool to v2.0.1"
- Create tag: "git-worktree-tool/v2.0.1"

### Claude Step 4: Ask Confirmation
```
"I've prepared the release. Ready to push?
This will create:
- Commit: Bump git-worktree-tool to v2.0.1
- Tag: git-worktree-tool/v2.0.1"
```

### User Confirms
```
"Yes, go ahead and push"
```

### Claude Step 5: Push
```
git push origin HEAD
git push origin "git-worktree-tool/v2.0.1"
```

### Claude Step 6: Verify
```
"Release complete! ✓
- Commit pushed
- Tag pushed to remote
- New version: 2.0.1
- View on GitHub: [tag link]"
```

---

## Error Handling

### If Version Mismatch Detected

```
"⚠️ Version mismatch detected!
- Embedded version: 2.0.0
- VERSION file: 2.0.1
- CHANGELOG: 2.0.0

These must match. Should I:
1. Update all to 2.0.0?
2. Update all to 2.0.1?
3. Investigate which is correct?"
```

### If User Requests Undocumented Version

```
"⚠️ Requested version doesn't follow semantic versioning.
Requested: 2.0.beta
Pattern required: MAJOR.MINOR.PATCH (e.g., 2.0.0)

Did you mean v2.0.0? Or is this a pre-release?"
```

### If CHANGELOG Entry Is Unclear

```
"I need more details for the CHANGELOG entry.

Change: 'Improved something'
Is this:
- A performance improvement?
- Better error messages?
- Fixed a bug?
- Added a new feature?

This determines where it goes in the CHANGELOG."
```

---

## Safety Checklist for Claude

Before pushing any release, verify ALL of these:

```
Pre-Push Verification:
[ ] Working directory is clean (git status --porcelain is empty)
[ ] Version matches in all 4 locations
[ ] New version follows semantic versioning (MAJOR.MINOR.PATCH)
[ ] CHANGELOG has new version section with proper date format
[ ] CHANGELOG entries are in correct sections (Added, Changed, Fixed, Breaking)
[ ] No unrelated files modified in this commit
[ ] Commit message format is correct: "Bump <skill> to v<version>"
[ ] Tag name format is correct: "<skill>/v<version>"
[ ] User confirmed push is ok

Post-Push Verification:
[ ] Commit appears in git log
[ ] Tag created successfully (git tag -l shows new tag)
[ ] Tag pushed to remote (git ls-remote --tags shows new tag)
[ ] Version command works: git-worktree-tool/wt --version shows 2.0.1
```

---

## Integration with User's CLAUDE.md Preferences

This workflow respects the user's preferences from CLAUDE.md:

**✓ Educational approach**
- Explain the semantic versioning decision
- Show the calculated new version
- Explain why each file needs updating

**✓ Incremental changes**
- One step at a time following docs/RELEASES.md
- Verify after each step
- Don't batch multiple operations

**✓ Clear signaling**
- Use ⚠️ for MAJOR bumps requiring confirmation
- Use ✓ for verification checkmarks
- Use clear step numbering

**✓ Review before implementation**
- Always ask before pushing (major step)
- Show exactly what will be pushed
- Give user chance to review

**✓ Using bun/npm appropriately**
- This is git-based process, npm/bun not directly involved
- But respect tool preferences if CLI tools are needed

---

## References

- **Complete process:** See `docs/RELEASES.md`
- **Metadata:** See `docs/.release-data.json`
- **Schema:** See `.release-schema.json`
- **Main docs:** See `README.md`

