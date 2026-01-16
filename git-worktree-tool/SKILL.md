---
name: git-worktree-guide
description: Git worktree management with the `wt` script for simplified create, list, switch, and delete operations. Includes comprehensive guidance on best practices and troubleshooting.
---

# Git Worktree Guide

## Skill Purpose

Provides a streamlined `wt` command-line tool and comprehensive guidance for git worktree operations. The `wt` script handles the fiddly parts (creating, switching, deleting) while this guide covers concepts, best practices, and troubleshooting.

---

## Quick Start: Using the `wt` Script

**The easiest way to manage worktrees is with the `wt` command:**

```bash
# List all worktrees
wt list

# Create a new worktree
wt create DEV-123

# Switch to a worktree
wt switch DEV-123

# Delete a worktree (and its branch)
wt delete DEV-123
```

**Setup:** See `INSTALL.md` for installation instructions.

---

## When to Use This Skill

- **Using the `wt` script** for everyday worktree operations (fastest path)
- **Learning worktree concepts** - why they exist and when to use them
- **Understanding best practices** for organizing and maintaining worktrees
- **Troubleshooting issues** that arise with worktrees
- **Comparing worktrees vs stash vs checkout** approaches
- **Advanced workflows** like running tests in parallel

---

## Foundation

### Key Concepts

**What are git worktrees?**
Git worktrees allow you to have multiple working directories for the same repository. Each worktree has its own branch checked out, enabling you to work on different features simultaneously without constantly switching contexts or stashing changes.

**Why use worktrees?**
- Keep mental context intact when working on multiple branches
- Run long builds/tests in one worktree while developing in another
- Review PRs without disrupting your current work
- Compare implementations side-by-side
- Avoid repetitive stash/checkout cycles

### Tools & Prerequisites

- **Primary Tool**: `git worktree` commands (built into git)
- **Supporting Tools**: Your terminal, git, and package manager (npm, yarn, bun, etc.)
- **Knowledge**: Basic git concepts (branches, commits, remotes)

### Key Principle

**Each worktree must have a unique branch checked out.** Git prevents the same branch from being checked out in multiple worktrees simultaneously. If you need to work on the same code in multiple places, create temporary branches.

---

## Decision Trees & When to Use Worktrees

### 1. When to Use Worktrees vs Other Approaches

**Use git worktrees when:**
- ✅ Working on multiple branches for more than 10-15 minutes
- ✅ Running long-running processes (builds, tests) while continuing development
- ✅ Comparing different branches side-by-side
- ✅ Reviewing PRs without losing your current work context
- ✅ You want each branch to have its own `node_modules` or build artifacts
- ✅ You need to context-switch between branches frequently

**Use git stash instead when:**
- 💼 Making a quick fix (5-10 minutes)
- 💼 Switching back to the same work within minutes
- 💼 You don't need to compare or run things simultaneously
- 💼 Disk space is limited (worktrees use extra space)

**Use git checkout when:**
- 🔄 Single-branch workflow
- 🔄 Comfortable with context switching
- 🔄 Simple back-and-forth between two branches
- 🔄 No long-running processes needed

### 2. Repository Context Detection

When you use this skill, it will automatically detect:

- **Branch naming pattern**: `DEV-123` (JIRA), `feature/name` (Git Flow), `username/branch` (Personal)
- **Package manager**: npm (package-lock.json), yarn (yarn.lock), bun (bun.lockb), pnpm (pnpm-lock.yaml)
- **Main branch name**: `master` or `main`
- **Current worktrees**: What's already set up
- **Repository location**: Where to create new worktrees

This allows the skill to provide commands and examples that match your specific repository setup.

---

## Common Workflows

### Workflow 1: Creating a New Worktree for a Feature Branch

**Scenario**: You're working on `DEV-123` but need to start `DEV-456` urgently.

**Step-by-Step Guide**:

```bash
# Step 1: Determine what you're creating
# - New branch from master? Use: git worktree add -b <new-branch>
# - Existing remote branch? Use: git worktree add <branch>

# Example for creating a NEW branch (most common):
git worktree add -b DEV-456 ../undercurrent-DEV-456 origin/master

# Example for EXISTING remote branch:
git worktree add ../undercurrent-DEV-789 origin/DEV-789

# Step 2: Navigate to the new worktree
cd ../undercurrent-DEV-456

# Step 3: Install dependencies (required for each worktree)
npm install

# Step 4: Start development
# Your changes to DEV-123 remain untouched in the other worktree
```

**Why each step matters:**
- `-b DEV-456`: Creates the branch and worktree together (cleaner than two commands)
- `../undercurrent-DEV-456`: Naming convention keeps worktrees organized
- `npm install`: Each worktree has its own `node_modules` (essential!)
- Shared git config: Changes you commit appear to all worktrees immediately

**Disk space note:** ⚠️ Each worktree needs ~500MB for `node_modules`. Having 3-4 worktrees uses 2GB+ disk space.

### Workflow 2: Running Builds While Developing

**Scenario**: You want to run a Storybook build in one worktree while coding in another.

**Step-by-Step**:

```bash
# In your main development worktree (Terminal 1):
cd ~/Documents/Repos/Work/undercurrent
npm run build-storybook  # Long-running build process

# In another terminal (Terminal 2):
cd ~/Documents/Repos/Work/undercurrent-DEV-123
# Continue developing, unblocked by the build in Terminal 1
```

**Why this works:**
- Each worktree has separate `node_modules`, build artifacts, etc.
- Changes in one worktree don't affect another's build
- You can run linting, tests, or builds in parallel

**Pro tip**: Open each worktree in a separate VS Code window to avoid IDE confusion:
```bash
code ~/Documents/Repos/Work/undercurrent
code ~/Documents/Repos/Work/undercurrent-DEV-123
```

### Workflow 3: Reviewing a PR Without Disrupting Work

**Scenario**: A teammate asks you to review their PR branch (`DEV-789`), but you're in the middle of `DEV-123`.

**Step-by-Step**:

```bash
# Step 1: Fetch the latest from remote
git fetch origin

# Step 2: Create a worktree for the PR branch
git worktree add ../undercurrent-review origin/DEV-789

# Step 3: Navigate and test
cd ../undercurrent-review
npm install
npm run storybook  # View their work
# Test functionality, read code

# Step 4: Return to your work (in original worktree)
cd ../undercurrent
# Your DEV-123 changes are exactly where you left them

# Step 5: Clean up the review worktree
cd ../undercurrent
git worktree remove ../undercurrent-review
```

**Why this matters:**
- Your work in DEV-123 is untouched
- You can actually test their code, not just read it
- Once done, remove the worktree to clean up

### Workflow 4: Comparing Two Branches Side-by-Side

**Scenario**: You want to compare your approach (`DEV-100`) with a teammate's approach (`DEV-101`).

**Step-by-Step**:

```bash
# Create both worktrees
git worktree add -b DEV-100 ../undercurrent-approach-a origin/master
git worktree add -b DEV-101 ../undercurrent-approach-b origin/master

# Open both in separate editor windows
code ../undercurrent-approach-a
code ../undercurrent-approach-b

# Now you can:
# - Compare file implementations side-by-side
# - Test both approaches
# - See which performs better
# - Make a decision

# Keep the better approach, remove the other
git worktree remove ../undercurrent-approach-b
```

---

## Best Practices

### 1. Directory Organization

**Naming Convention:**
```
undercurrent/                      # Main worktree (current work)
undercurrent-DEV-123/             # Feature branch
undercurrent-DEV-456/             # Another feature
undercurrent-master/              # Optional: clean master for comparisons
```

**Why this helps:**
- Easy to identify what each worktree is for
- Consistent naming prevents confusion
- Quick to locate worktrees in terminal

### 2. Dependency Management

**Critical**: Each worktree needs its own dependencies installed.

```bash
# After creating a worktree
git worktree add -b DEV-123 ../undercurrent-DEV-123 origin/master
cd ../undercurrent-DEV-123
npm install  # ⚠️ Essential - don't skip this!
```

**Lock file considerations:**
- `package-lock.json` is shared across worktrees (lives in `.git` space)
- If you update dependencies in one worktree, the lock file changes
- Other worktrees will see this change and need to `npm install` again

**Example**:
```bash
# In worktree DEV-123, you upgrade a package
npm install lodash@latest

# This changes package-lock.json (shared)
git add package-lock.json
git commit -m "DEV-123: upgrade lodash"

# In worktree DEV-456, you need to sync:
cd ../undercurrent-DEV-456
git pull origin master  # Get the lock file update
npm install  # Update node_modules to match
```

### 3. Disk Space Management

**Monitor worktree disk usage:**
```bash
# See all worktrees and their size impact
git worktree list

# Clean up node_modules from unused worktrees
cd ../unused-worktree
rm -rf node_modules  # Before removing the worktree

# Remove worktree
cd ../main-worktree
git worktree remove ../unused-worktree
```

**Budget:**
- Main worktree: ~500MB for dependencies
- Each additional worktree: ~500MB for dependencies
- 4 worktrees ≈ 2GB of disk usage

### 4. When to Choose Worktrees vs Stash vs Checkout

**Decision flowchart:**

```
How long will you work on this branch?
│
├─ < 5 minutes → Use: git checkout (simple switch)
│
├─ 5-15 minutes → Use: git stash (temporary switch)
│
└─ > 15 minutes → Use: worktree (serious parallel work)
```

**Practical example:**
```bash
# Quick fix (< 5 min) - just checkout
git checkout master
# Fix the thing
git checkout DEV-123

# Temporary review (5-15 min) - use stash
git stash
git checkout DEV-789  # Review PR
git checkout DEV-123
git stash pop

# Parallel development (> 15 min) - use worktree
git worktree add -b DEV-456 ../undercurrent-DEV-456 origin/master
# Serious work in both places
```

---

## Tool Reference

### Creating Worktrees

```bash
# Create worktree with a NEW branch
git worktree add -b <new-branch> ../<dir-name> origin/master

# Example:
git worktree add -b DEV-123 ../undercurrent-DEV-123 origin/master

# Create worktree from EXISTING remote branch
git worktree add ../<dir-name> origin/<branch-name>

# Example:
git worktree add ../undercurrent-DEV-456 origin/DEV-456
```

### Listing Worktrees

```bash
# See all active worktrees
git worktree list

# Output example:
# /path/to/undercurrent              abc1234 [master]
# /path/to/undercurrent-DEV-123      def5678 [DEV-123]
# /path/to/undercurrent-DEV-456      ghi9012 [DEV-456]
```

### Switching Between Worktrees

```bash
# Simple terminal approach
cd ../undercurrent-DEV-123

# Editor approach (preferred)
code ../undercurrent-DEV-123

# VS Code: Opens new window for the worktree
```

### Removing Worktrees

```bash
# Safe removal (must run from DIFFERENT worktree)
cd ../undercurrent
git worktree remove ../undercurrent-DEV-123

# Force removal (⚠️ use only if you're sure)
git worktree remove --force ../undercurrent-DEV-123

# Clean up stale references
git worktree prune
```

### Synchronizing Worktrees

```bash
# Fetch latest changes (affects all worktrees)
git fetch origin

# In a specific worktree, update local branch
cd ../undercurrent-DEV-123
git pull origin master  # Merge master into your branch
# or
git rebase origin/master  # Rebase your work on latest master
```

---

## Gotchas & Troubleshooting

### ❌ Problem: "Branch is already checked out at..."

**What happened:**
```bash
git worktree add ../undercurrent-DEV-123 DEV-123
# Error: 'DEV-123' is already checked out at '/path/to/undercurrent'
```

**Why:**
Git prevents the same branch from being in multiple worktrees. This is a safety feature.

**Solutions:**

*Option 1:* Remove the other worktree
```bash
git worktree remove ../undercurrent
# Then create new worktree with that branch
```

*Option 2:* Create a temporary branch
```bash
git worktree add -b DEV-123-temp ../undercurrent-DEV-123-temp DEV-123
# Now you have DEV-123 in two places (original + temp)
```

*Option 3:* Check where it's checked out
```bash
git worktree list  # Shows all locations
```

### ❌ Problem: "Removing worktree fails - uncommitted changes"

**What happened:**
```bash
git worktree remove ../undercurrent-DEV-123
# Error: cannot remove working tree - have uncommitted changes
```

**Why:**
Git protects your work by refusing to remove worktrees with unsaved changes.

**Solutions:**

*Option 1:* Commit the changes (recommended)
```bash
cd ../undercurrent-DEV-123
git add .
git commit -m "DEV-123: save work before removing worktree"
cd ../undercurrent
git worktree remove ../undercurrent-DEV-123
```

*Option 2:* Stash the changes
```bash
cd ../undercurrent-DEV-123
git stash
cd ../undercurrent
git worktree remove ../undercurrent-DEV-123
```

*Option 3:* Force remove (⚠️ CAUTION - loses work)
```bash
git worktree remove --force ../undercurrent-DEV-123
# This deletes uncommitted work permanently
```

### ❌ Problem: npm install in worktree is very slow or fails

**What happened:**
```bash
cd ../undercurrent-DEV-123
npm install
# Takes forever or has permission errors
```

**Why:**
- Git objects are shared (fast), but `node_modules` is separate (slow)
- Permission issues from shared git config

**Solutions:**

*Option 1:* Ensure git fetch is done first
```bash
git fetch origin  # Do this once, benefits all worktrees
cd ../undercurrent-DEV-123
npm install  # Should be faster now
```

*Option 2:* Check npm cache
```bash
npm cache verify  # Fix potential cache issues
npm install
```

*Option 3:* Use npm ci instead of npm install
```bash
npm ci  # Cleaner install, respects lock file exactly
```

### ❌ Problem: IDE confusion - wrong files showing as changed

**What happened:**
Your IDE shows files as changed/deleted because you're working in worktree DEV-123 but the IDE thinks you're in DEV-456.

**Why:**
IDEs can get confused when multiple worktrees are open in the same editor.

**Solutions:**

*Option 1:* Open separate VS Code windows (recommended)
```bash
code ../undercurrent          # Window 1
code ../undercurrent-DEV-123  # Window 2
```

Each window gets its own git/file context.

*Option 2:* Close other worktree windows
Close any IDE windows pointing to other worktrees while working.

*Option 3:* Use workspace settings
Create `.vscode/settings.json` in each worktree with distinct settings.

### ❌ Problem: "Stale worktree references" after manual deletion

**What happened:**
You deleted a worktree directory manually (not using `git worktree remove`), and now `git worktree list` shows it.

**Symptoms:**
```bash
git worktree list
# Shows /path/to/undercurrent-DEV-123 (broken link)
```

**Solution:**
```bash
# Clean up stale references
git worktree prune

# Verify cleanup
git worktree list
```

### ❌ Problem: Package lock file conflicts between worktrees

**What happened:**
You updated dependencies in DEV-123, now DEV-456 has lock file conflicts.

**Why:**
Lock files are shared, but `node_modules` are separate per worktree.

**Solution:**

```bash
# In DEV-123 (where you made changes)
git add package-lock.json
git commit -m "DEV-123: update dependencies"
git push origin DEV-123

# In DEV-456 (affected worktree)
git fetch origin
git pull origin master  # Get the updated lock file
npm install  # Resync node_modules with new lock file
```

**Prevention:**
Commit lock file changes immediately when you update dependencies.

---

## Quick Decision Flowchart

```
Do you need to work with multiple branches?
│
├─ "I need to switch between 2 branches repeatedly"
│  ├─ Will take < 5 min each switch? → Use: git checkout
│  └─ Will take > 5 min each switch? → Use: git worktree
│
├─ "I need to test/compare two implementations"
│  └─ Create 2 worktrees, open side-by-side
│
├─ "I have a long build running"
│  └─ Use: git worktree (separate build in separate worktree)
│
├─ "I need to review a PR"
│  └─ Use: git worktree (create temp worktree for review)
│
├─ "I have uncommitted work and need to switch"
│  ├─ Will return in < 5 min? → Use: git stash
│  └─ Will return later? → Use: git worktree
│
└─ "I'm not sure"
   └─ Worktrees are safe and reversible - create one!
```

---

## Best Practices Recap

✅ **Do:**
- Use naming convention: `repo-name-branch-name`
- Run `npm install` in each new worktree
- Open each worktree in its own IDE window
- Commit lock file changes immediately
- Use `git worktree list` to see what's active
- Clean up worktrees you're not using

❌ **Don't:**
- Check out the same branch in multiple worktrees
- Forget to `npm install` in new worktrees
- Manually delete worktree directories
- Open the same worktree in multiple IDE windows
- Leave many unused worktrees active (disk space)
- Use force removal unless absolutely necessary

---

## The `wt` Script vs Raw Git Commands

### Why Use `wt`?

The `wt` script handles:
- ✅ Repository and package manager auto-detection
- ✅ Correct path naming (`../repo-name-branch`)
- ✅ Automatic dependency installation (bun/npm/yarn/pnpm)
- ✅ Safe deletion with uncommitted changes prompts
- ✅ Clean output formatting
- ✅ Shell integration for directory switching

**Without `wt`**, you'd do this manually:
```bash
# Get repo name and default branch
repo_root=$(git rev-parse --show-toplevel)
repo_name=$(basename "$repo_root")
default_branch=$(git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@')

# Create worktree
git worktree add -b DEV-123 ../${repo_name}-DEV-123 origin/$default_branch

# cd to it
cd ../${repo_name}-DEV-123

# Install dependencies
bun install  # or npm/yarn/pnpm
```

**With `wt`, you just do:**
```bash
wt create DEV-123
```

---

## Skill Version & Updates

- **Version**: 2.0.0
- **Last Updated**: January 16, 2026
- **Changelog**: See [releases/git-worktree-tool/CHANGELOG.md](../releases/git-worktree-tool/CHANGELOG.md) for version history
- **Skill Type**: Practical tool + comprehensive guidance
- **Scope**: Git worktree operations with automated `wt` script
- **Learning Mode**: Yes - explains WHY, not just HOW

**Quick start:** Run `wt list` to see your worktrees. See `INSTALL.md` for setup.

**For learning:** This guide covers concepts, best practices, troubleshooting, and decision trees that help you understand when and why to use worktrees.
