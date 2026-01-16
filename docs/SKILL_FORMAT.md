# Skill Format Specification

This document describes the required and optional file formats for skills in the Skills Workshop repository.

## Directory Structure

Each skill follows this structure:

```
<skill-name>/
  SKILL.md           # Required: Main skill documentation
  INSTALL.md         # Required: Installation instructions
  <script>           # Optional: Executable tool (if skill includes one)
  PLAN.md            # Optional: Development planning notes

releases/<skill-name>/
  VERSION            # Required: Current version number
  CHANGELOG.md       # Required: Version history
```

## Required Files

### SKILL.md

The main documentation file with YAML frontmatter. This is the primary file Claude Code reads to understand the skill.

**Format:**

```markdown
---
name: skill-name
description: Brief one-line description of what the skill does
---

# Skill Title

## Skill Purpose

What this skill provides and when to use it.

## Quick Start

Basic usage examples.

## [Additional Sections]

Detailed documentation, best practices, troubleshooting, etc.

## Skill Version & Updates

- **Version**: X.Y.Z
- **Last Updated**: Month DD, YYYY
```

**YAML Frontmatter Fields:**

| Field | Required | Description |
|-------|----------|-------------|
| `name` | Yes | Skill identifier (matches directory name, kebab-case) |
| `description` | Yes | Brief description for skill discovery |

### INSTALL.md

Installation and setup instructions for users.

**Should include:**
- Prerequisites (tools, dependencies)
- Step-by-step installation process
- Configuration options
- Verification steps

### VERSION (in releases/)

Plain text file containing only the current version number.

**Format:**
```
2.1.0
```

- Single line, no trailing newline required
- Follows semantic versioning (MAJOR.MINOR.PATCH)

### CHANGELOG.md (in releases/)

Version history following [Keep a Changelog](https://keepachangelog.com/) format.

**Format:**

```markdown
# Changelog

All notable changes to this skill will be documented in this file.

## [2.1.0] - 2026-01-16

### Added
- New feature X

### Changed
- Updated behavior of Y

### Fixed
- Bug in Z

## [2.0.0] - 2026-01-15

### Added
- Initial release
```

## Optional Files

### Executable Script

If your skill includes a tool, it should:

- Be named in lowercase without extension (e.g., `wt`)
- Include embedded version: `VERSION="X.Y.Z"`
- Support `--version` and `--help` flags
- Use meaningful exit codes (0 = success)
- Be ShellCheck-compliant for bash scripts

### PLAN.md

Development planning notes. Useful for:
- Tracking feature ideas
- Documenting design decisions
- Planning implementation steps

## Versioning Guidelines

Skills use semantic versioning:

- **MAJOR** (X.0.0): Breaking changes, incompatible API changes
- **MINOR** (0.X.0): New features, backward-compatible
- **PATCH** (0.0.X): Bug fixes, documentation updates

### Version Locations

Versions should be kept in sync across:
1. `releases/<skill>/VERSION` - Source of truth
2. Skill script's `VERSION` variable (if applicable)
3. SKILL.md's "Skill Version & Updates" section

## Naming Conventions

| Element | Convention | Example |
|---------|------------|---------|
| Skill directory | `kebab-case` | `git-worktree-tool` |
| Script name | `lowercase` | `wt` |
| Documentation | `UPPERCASE.md` | `SKILL.md`, `INSTALL.md` |

## Example: Minimal Skill

```
my-tool/
  SKILL.md       # Documentation with YAML frontmatter
  INSTALL.md     # Installation steps

releases/my-tool/
  VERSION        # Contains: 1.0.0
  CHANGELOG.md   # Version history
```

## Example: Full Skill with Script

```
git-worktree-tool/
  wt             # Executable script
  SKILL.md       # Full documentation
  INSTALL.md     # Setup instructions
  PLAN.md        # Development notes

releases/git-worktree-tool/
  VERSION        # Current version
  CHANGELOG.md   # Release history
```
