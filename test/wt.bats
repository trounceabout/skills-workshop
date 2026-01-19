#!/usr/bin/env bats
# BATS tests for the wt (worktree) script
# Run with: bats test/wt.bats

# Path to the wt script being tested
WT_SCRIPT="${BATS_TEST_DIRNAME}/../git-worktree-tool/wt"

setup() {
  # Create a temporary directory for each test
  TEST_DIR=$(mktemp -d)
  cd "$TEST_DIR"

  # Initialize a git repo with an initial commit
  git init --quiet
  git config user.email "test@example.com"
  git config user.name "Test User"
  git commit --allow-empty -m "Initial commit" --quiet

  # Create main branch if it doesn't exist
  git branch -M main
}

teardown() {
  # Clean up the temporary directory
  cd /
  rm -rf "$TEST_DIR"
}

# ============================================================================
# Version and Help Tests
# ============================================================================

@test "wt --version shows version" {
  run "$WT_SCRIPT" --version
  [ "$status" -eq 0 ]
  [[ "$output" =~ "wt version" ]]
}

@test "wt -v shows version" {
  run "$WT_SCRIPT" -v
  [ "$status" -eq 0 ]
  [[ "$output" =~ "wt version" ]]
}

@test "wt help shows usage" {
  run "$WT_SCRIPT" help
  [ "$status" -eq 0 ]
  [[ "$output" =~ "USAGE:" ]]
  [[ "$output" =~ "COMMANDS:" ]]
}

@test "wt --help shows usage" {
  run "$WT_SCRIPT" --help
  [ "$status" -eq 0 ]
  [[ "$output" =~ "USAGE:" ]]
}

# ============================================================================
# List Command Tests
# ============================================================================

@test "wt list works in git repo" {
  run "$WT_SCRIPT" list
  [ "$status" -eq 0 ]
  [[ "$output" =~ "Current worktrees:" ]]
}

@test "wt list fails outside git repo" {
  cd /tmp
  run "$WT_SCRIPT" list
  [ "$status" -eq 1 ]
  [[ "$output" =~ "Not a git repository" ]]
}

# ============================================================================
# Branch Name Validation Tests
# ============================================================================

@test "wt create rejects branch name with spaces" {
  run "$WT_SCRIPT" create "invalid branch"
  [ "$status" -eq 1 ]
  [[ "$output" =~ "cannot contain spaces" ]]
}

@test "wt create rejects branch name with special characters" {
  run "$WT_SCRIPT" create "branch~name"
  [ "$status" -eq 1 ]
  [[ "$output" =~ "invalid characters" ]]
}

@test "wt create rejects branch name starting with dot" {
  run "$WT_SCRIPT" create ".hidden"
  [ "$status" -eq 1 ]
  [[ "$output" =~ "cannot start or end" ]]
}

@test "wt create rejects branch name with consecutive dots" {
  run "$WT_SCRIPT" create "branch..name"
  [ "$status" -eq 1 ]
  [[ "$output" =~ "cannot contain '..'" ]]
}

@test "wt create rejects empty branch name" {
  run "$WT_SCRIPT" create ""
  [ "$status" -eq 1 ]
  [[ "$output" =~ "Branch name required" ]]
}

# ============================================================================
# Switch Command Tests
# ============================================================================

@test "wt switch requires branch name" {
  run "$WT_SCRIPT" switch
  [ "$status" -eq 1 ]
  [[ "$output" =~ "Branch name required" ]]
}

@test "wt switch fails for non-existent worktree" {
  run "$WT_SCRIPT" switch "nonexistent-branch"
  [ "$status" -eq 1 ]
  [[ "$output" =~ "Worktree not found" ]]
}

# ============================================================================
# Delete Command Tests
# ============================================================================

@test "wt delete requires branch name" {
  run "$WT_SCRIPT" delete
  [ "$status" -eq 1 ]
  [[ "$output" =~ "Branch name required" ]]
}

@test "wt delete fails for non-existent worktree" {
  run "$WT_SCRIPT" delete "nonexistent-branch"
  [ "$status" -eq 1 ]
  [[ "$output" =~ "Worktree not found" ]]
}

# ============================================================================
# Unknown Command Tests
# ============================================================================

@test "wt unknown command shows error" {
  run "$WT_SCRIPT" foobar
  [ "$status" -eq 1 ]
  [[ "$output" =~ "Unknown command" ]]
}
