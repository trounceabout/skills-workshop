# Installing the `wt` Worktree Management Script

The `wt` script provides a simple, intuitive interface for managing git worktrees. Follow these steps to set it up.

## Quick Setup

### 1. Verify the Script Location

The `wt` script is already located at:
```
~/.claude/skills/git-worktree-guide/wt
```

Verify it's executable:
```bash
ls -l ~/.claude/skills/git-worktree-guide/wt
# Should show: -rwxr-xr-x (executable)
```

### 2. Add the Shell Function to Your Shell Configuration

For the `wt switch` command to actually change your directory, you need a shell function. Add this to your `~/.zshrc` (or `~/.bashrc` if using bash):

```bash
# Git Worktree Management
wt() {
  local script="$HOME/.claude/skills/git-worktree-guide/wt"

  # For switch command, source the output to change directory
  if [ "$1" = "switch" ] || ([ $# -eq 1 ] && [ "$1" != "list" ] && [ "$1" != "create" ] && [ "$1" != "delete" ] && [ "$1" != "help" ]); then
    local output=$("$script" "$@")
    if [ $? -eq 0 ]; then
      # Execute the cd command in current shell
      eval "$output"
    else
      echo "$output"
    fi
  else
    "$script" "$@"
  fi
}
```

**To add this:**

```bash
# Open your shell config in your editor
code ~/.zshrc  # or vim ~/.zshrc

# Paste the function above
# Save and exit

# Reload your shell config
source ~/.zshrc
```

### 3. Test the Installation

```bash
# Navigate to a git repository
cd ~/Documents/Repos/Work/undercurrent

# Try listing worktrees (should show at least the main one)
wt list

# You should see output like:
# Current worktrees:
# ✓ undercurrent              [main]
```

If you see the above, you're all set!

## Usage

### Create a New Worktree

```bash
# In your main repo
wt create DEV-123

# With VS Code open
wt create DEV-123 --code
```

This will:
1. Create a new git worktree: `../undercurrent-DEV-123`
2. Create a new branch: `DEV-123`
3. Automatically run `bun install` (or detected package manager)
4. Optionally open VS Code (with `--code` flag)

### List All Worktrees

```bash
wt list
```

Shows all active worktrees with:
- `✓` (checkmark) for your current worktree
- `•` (bullet) for other worktrees
- Branch name in brackets

### Switch to a Worktree

```bash
wt switch DEV-123
# or shorthand:
wt DEV-123
```

This actually changes your directory to the worktree (thanks to the shell function).

### Delete a Worktree

```bash
wt delete DEV-123

# Delete worktree but keep the branch
wt delete DEV-123 --keep-branch
```

When deleting, you can:
- **Commit** uncommitted changes
- **Stash** uncommitted changes
- **Force delete** (⚠️ loses uncommitted work)
- **Cancel** the deletion

The default behavior deletes both the worktree and the git branch.

## Troubleshooting

### "Command not found: wt"

**Problem:** The shell function isn't installed or loaded.

**Solution:**
1. Verify the script exists: `ls -l ~/.claude/skills/git-worktree-guide/wt`
2. Add the shell function to `~/.zshrc` (see "Add the Shell Function" above)
3. Reload your shell: `source ~/.zshrc`

### "Not a git repository"

**Problem:** You're not in a git repository.

**Solution:**
```bash
# Navigate to a git repository
cd ~/path/to/your/repo

# Then try again
wt list
```

### Switch command just outputs "cd" instead of changing directory

**Problem:** The shell function isn't working.

**Solution:**
1. Check your shell function is in `~/.zshrc`: `grep -A 10 "wt()" ~/.zshrc`
2. Make sure you've reloaded: `source ~/.zshrc`
3. Test in a new terminal window

### "Worktree already exists"

**Problem:** Trying to create a worktree with an existing name.

**Solution:**
```bash
# List what's already there
wt list

# Use a different branch name
wt create DEV-124  # instead of DEV-123
```

## Advanced Tips

### Create an Alias (Optional)

If you prefer shorter commands:

```bash
# Add to ~/.zshrc
alias w='wt'

# Then use:
w create DEV-123
w list
w switch DEV-123
```

### Add to Your PATH (Optional)

Make `wt` available globally:

```bash
# Create a symlink in a directory on your PATH
# For example, if ~/.local/bin is on your PATH:
ln -s ~/.claude/skills/git-worktree-guide/wt ~/.local/bin/wt

# Then use from anywhere:
wt list
```

### Opening Multiple Worktrees in VS Code

```bash
# Open main repo in one window
code ~/Documents/Repos/Work/undercurrent

# Open worktree in another window
code ~/Documents/Repos/Work/undercurrent-DEV-123

# Now you can compare side-by-side in separate windows
```

## Common Workflows

### Workflow 1: Create and Develop

```bash
# In your main repo
wt create DEV-123 --code

# VS Code opens automatically
# You're ready to start coding

# When done:
wt delete DEV-123
```

### Workflow 2: Review a PR While Working

```bash
# Create a temporary worktree for review
wt create review-pr --code

# In that worktree, fetch and test the PR
git fetch origin
git checkout PR-branch-name  # if needed

# Switch back to your work
wt switch main-branch-name

# When done reviewing:
wt delete review-pr --keep-branch
```

### Workflow 3: Running Tests in Parallel

```bash
# Terminal 1: Create worktree for long-running tests
wt create testing
cd ../undercurrent-testing
npm test

# Terminal 2: Continue developing in main
cd ../undercurrent
# Make changes, commit, etc.
```

## Understanding the Shell Function

The shell function in `~/.zshrc` handles the magic of actually changing your directory. Here's what it does:

1. **For switch commands**: Captures the output (`cd <path>`) and runs it with `eval`
2. **For other commands**: Passes directly to the script (list, create, delete)

This is necessary because a subprocess (the script) can't change the parent shell's directory. The function acts as a bridge.

```bash
wt switch DEV-123
# The shell function:
# 1. Calls: ~/.claude/skills/git-worktree-guide/wt switch DEV-123
# 2. Gets output: cd /path/to/undercurrent-DEV-123
# 3. Runs: eval "cd /path/to/undercurrent-DEV-123"
# 4. Your shell directory actually changes!
```

## Getting Help

```bash
# Show built-in help
wt help

# This displays all commands and options
```

---

**Need help with the original git-worktree-guide skill?** See `SKILL.md` for detailed information about git worktree concepts, best practices, and troubleshooting.
