# Add Configuration System to `wt` Worktree Script

## Overview
Add a simple configuration system to make `wt` customizable without needing to edit the script directly. This will allow users to configure their preferred editor, package manager preferences, and other behaviors through a config file.

## Current State
- `wt` script is working with hardcoded behavior
- Editor is hardcoded to `code` (VS Code)
- Package manager is auto-detected (bun > npm > yarn > pnpm)
- Flags: `--code`, `--go`, `--keep-branch`

## Problem Statement
Making the tool customizable currently requires:
- Editing the bash script directly (intimidating for non-developers)
- Risk of breaking the script with syntax errors
- No easy way to share/version personal preferences
- Hardcoded to VS Code - what about users who prefer other editors?

## Proposed Solution: Simple Config File Approach

### Design Philosophy
**Keep it simple:** A single config file with key=value pairs, no complex CLI installer needed.

### Configuration File Location
`~/.config/wt/config` (follows XDG Base Directory specification)

### Configuration Options

```bash
# ~/.config/wt/config

# Editor command (default: code)
# Examples: code, cursor, zed, nvim, subl
EDITOR=code

# Editor flags for opening directories (default: none)
# Examples: -n (VS Code new window), --wait (block until closed)
EDITOR_FLAGS=

# Auto-install dependencies after creating worktree (default: true)
AUTO_INSTALL=true

# Delete branch by default when deleting worktree (default: true)
DELETE_BRANCH_DEFAULT=true

# Package manager preference order (default: auto-detect)
# Set this to force a specific package manager: bun, npm, yarn, pnpm
PACKAGE_MANAGER=

# Worktree naming pattern (default: {repo}-{branch})
# Variables: {repo}, {branch}
WORKTREE_NAME_PATTERN={repo}-{branch}
```

### Implementation Approach

**No CLI installer needed!** Instead:

1. **Auto-create config on first run** with defaults if it doesn't exist
2. **Add `wt config` command** to:
   - `wt config edit` - Opens config in $EDITOR
   - `wt config show` - Displays current config
   - `wt config reset` - Resets to defaults
3. **Inline comments** in the generated config explain each option

### Difficulty Assessment

| Task | Difficulty | Why |
|------|------------|-----|
| Load config file | Easy | Simple bash `source` or line parsing |
| Use config values | Easy | Replace hardcoded values with variables |
| Create default config | Easy | Write template file on first run |
| `wt config` subcommands | Easy | Add command parsing for config operations |
| **Overall** | **Easy-Medium** | ~1-2 hours of work, minimal complexity |

### Benefits of Config File vs CLI Installer

✅ **Simpler**: No installation ceremony, just edit a text file
✅ **Transparent**: Users can see all options at once
✅ **Versionable**: Config can be committed to dotfiles repo
✅ **Portable**: Copy config to new machine easily
✅ **Familiar**: Follows Unix convention (like `.gitconfig`)

❌ **CLI Installer would add**:
- Interactive prompts (more code, more testing)
- Validation logic (what if user enters invalid values?)
- Update mechanism (how to add new options later?)
- More complexity for marginal benefit

## Implementation Plan

### Files to Modify/Create

1. **`/Users/trounceabout/.claude/skills/git-worktree-guide/wt`** (modify)
   - Add config loading function at top
   - Replace hardcoded values with config variables
   - Add `wt config` subcommand

2. **`~/.config/wt/config`** (auto-generated on first run)
   - Default configuration file with inline documentation

### Implementation Steps

#### Step 1: Add Config Loading Function
```bash
# Near top of wt script, after color definitions
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/wt"
CONFIG_FILE="$CONFIG_DIR/config"

# Default values
EDITOR="${EDITOR:-code}"
EDITOR_FLAGS="${EDITOR_FLAGS:-}"
AUTO_INSTALL="${AUTO_INSTALL:-true}"
DELETE_BRANCH_DEFAULT="${DELETE_BRANCH_DEFAULT:-true}"
PACKAGE_MANAGER="${PACKAGE_MANAGER:-}"
WORKTREE_NAME_PATTERN="${WORKTREE_NAME_PATTERN:-{repo}-{branch}}"

load_config() {
  if [ -f "$CONFIG_FILE" ]; then
    # Source config file (sets variables)
    source "$CONFIG_FILE"
  else
    # Create default config on first run
    create_default_config
  fi
}

create_default_config() {
  mkdir -p "$CONFIG_DIR"
  cat > "$CONFIG_FILE" << 'EOF'
# wt - Worktree Management Configuration
# Edit this file to customize wt behavior

# Editor command to use with --code and --go flags (default: code)
# Examples: cursor, zed, nvim, subl, idea
EDITOR=code

# Flags to pass to editor (optional)
# Examples: -n (new window), --wait (block until closed)
EDITOR_FLAGS=

# Auto-install dependencies after creating worktree (default: true)
AUTO_INSTALL=true

# Delete branch by default when deleting worktree (default: true)
DELETE_BRANCH_DEFAULT=true

# Force a specific package manager (leave empty for auto-detect)
# Options: bun, npm, yarn, pnpm
PACKAGE_MANAGER=

# Worktree naming pattern (default: {repo}-{branch})
# Variables: {repo} = repo name, {branch} = branch name
WORKTREE_NAME_PATTERN={repo}-{branch}
EOF
  info "Created config file at: $CONFIG_FILE"
  info "Run 'wt config edit' to customize"
}
```

#### Step 2: Update Code to Use Config Values

**Replace hardcoded `code` calls:**
```bash
# Old:
code "$worktree_full_path" &

# New:
$EDITOR $EDITOR_FLAGS "$worktree_full_path" &
```

**Use DELETE_BRANCH_DEFAULT:**
```bash
# In cmd_delete, change the prompt logic based on config
if [ "$DELETE_BRANCH_DEFAULT" = "true" ]; then
  # Prompt: "Delete branch too? [Y/n]" (default yes)
else
  # Prompt: "Delete branch too? [y/N]" (default no)
fi
```

**Use PACKAGE_MANAGER if set:**
```bash
get_package_manager() {
  # If PACKAGE_MANAGER is set in config, use it
  if [ -n "$PACKAGE_MANAGER" ]; then
    echo "$PACKAGE_MANAGER"
    return
  fi

  # Otherwise auto-detect (existing logic)
  local repo_root=$(get_repo_root)
  if [ -f "$repo_root/bun.lockb" ]; then
    echo "bun"
  # ... rest of auto-detect logic
}
```

**Use WORKTREE_NAME_PATTERN:**
```bash
# In cmd_create:
# Old:
local worktree_path="../${repo_name}-${branch_name}"

# New:
local worktree_name=$(echo "$WORKTREE_NAME_PATTERN" | sed "s/{repo}/$repo_name/g" | sed "s/{branch}/$branch_name/g")
local worktree_path="../${worktree_name}"
```

#### Step 3: Add `wt config` Subcommand

```bash
cmd_config() {
  local subcommand="${1:-show}"

  case "$subcommand" in
    edit)
      # Open config in $EDITOR (or fallback to system default)
      ${EDITOR:-${VISUAL:-vi}} "$CONFIG_FILE"
      ;;
    show)
      if [ -f "$CONFIG_FILE" ]; then
        cat "$CONFIG_FILE"
      else
        error "Config file not found. Run 'wt config edit' to create it."
      fi
      ;;
    reset)
      if [ -f "$CONFIG_FILE" ]; then
        read -p "Reset config to defaults? This will overwrite $CONFIG_FILE [y/N] " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
          create_default_config
          success "Config reset to defaults"
        fi
      else
        create_default_config
      fi
      ;;
    path)
      echo "$CONFIG_FILE"
      ;;
    *)
      error "Unknown config subcommand: $subcommand. Use: edit, show, reset, path"
      ;;
  esac
}
```

#### Step 4: Update Help Text

Add to `cmd_help()`:
```
COMMANDS:
  config [edit|show|reset|path]  Manage wt configuration
```

#### Step 5: Call load_config in main()

```bash
main() {
  # Load config before processing commands
  load_config

  local command="${1:-help}"
  # ... rest of command dispatch
```

### Testing Plan

1. **Test config creation:**
   ```bash
   rm -rf ~/.config/wt  # Clean slate
   wt list              # Should auto-create config
   cat ~/.config/wt/config  # Verify defaults
   ```

2. **Test config editing:**
   ```bash
   wt config edit       # Opens in editor
   wt config show       # Displays config
   ```

3. **Test custom editor:**
   ```bash
   echo "EDITOR=cursor" >> ~/.config/wt/config
   wt create TEST-123 --code  # Should open in Cursor
   ```

4. **Test package manager override:**
   ```bash
   echo "PACKAGE_MANAGER=npm" >> ~/.config/wt/config
   wt create TEST-456  # Should use npm even if bun.lockb exists
   ```

5. **Test config reset:**
   ```bash
   wt config reset     # Should prompt and reset
   ```

## Alternative: Environment Variables Only

A simpler alternative without config file:

```bash
# Users set in their ~/.zshrc:
export WT_EDITOR=cursor
export WT_AUTO_INSTALL=false
export WT_DELETE_BRANCH_DEFAULT=false

# Script reads these:
EDITOR="${WT_EDITOR:-code}"
AUTO_INSTALL="${WT_AUTO_INSTALL:-true}"
# etc.
```

**Pros:**
- Even simpler implementation
- No file management needed
- Already in dotfiles (zshrc)

**Cons:**
- Less discoverable (users don't know what to set)
- Can't easily see all options at once
- No inline documentation

**Recommendation:** Use config file approach - better user experience.

## Success Criteria

✅ Config file auto-created on first run with sensible defaults
✅ `wt config edit` opens config in user's editor
✅ `wt config show` displays current settings
✅ Custom editor works with `--code` and `--go` flags
✅ All config options properly documented inline
✅ Backward compatible (works without config file)
✅ No breaking changes to existing `wt` commands

## Difficulty: **Easy-Medium** ⭐⭐

- Straightforward bash scripting (similar to existing code)
- No complex validation or CLI prompts needed
- Config file is simple key=value format
- Estimated time: 1-2 hours implementation + testing
- No installer needed - keeps it simple

## Next Steps After Implementation

Future enhancements (optional):
- `wt config validate` - Check for invalid config values
- Support for per-repo config (`.wt/config` in repo root)
- More customization options based on user feedback
