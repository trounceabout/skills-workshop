# Changelog - git-worktree-tool

All notable changes to the git-worktree-tool skill are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.1.1] - 2026-01-16

### Added
- Comprehensive agent-friendly release documentation in `docs/RELEASES.md`
- Claude Code-specific release workflow in `.claude/release-instructions.md`
- Machine-readable release metadata in `docs/.release-data.json`
- JSON schema for release data validation in `.release-schema.json`
- Documentation section in README.md linking to release guides

### Improved
- Release process now has decision trees for semantic versioning
- Step-by-step validation checklists for all release steps
- Multi-audience documentation (AI agents, humans)
- Safety guardrails and troubleshooting guidance

## [2.1.0] - 2026-01-16

### Added
- Comprehensive configuration system via `~/.config/wt/config`
- New `wt config` subcommands: `show`, `edit`, `reset`, `path`
- Configuration options for customizing tool behavior:
  - `EDITOR` - Choose your editor (code, cursor, zed, nvim, vim, etc.)
  - `EDITOR_FLAGS` - Pass editor-specific flags (e.g., `--remote=wsl`)
  - `AUTO_INSTALL` - Control automatic dependency installation
  - `DELETE_BRANCH_PROMPT` - Skip confirmation when deleting branches
  - `PACKAGE_MANAGER` - Override package manager auto-detection
  - `WORKTREE_NAME_PATTERN` - Customize worktree directory naming with variable substitution
- XDG Base Directory spec compliance for config file location
- Variable substitution in worktree naming patterns (`{repo}`, `{branch}`)
- Configuration documentation in SKILL.md with usage examples

### Changed
- Editor integration now uses configurable `EDITOR` and `EDITOR_FLAGS` instead of hardcoded `code`
- Dependency installation now respects `AUTO_INSTALL` configuration option
- Branch deletion prompts now respect `DELETE_BRANCH_PROMPT` configuration
- Package manager detection can be overridden via configuration
- Updated help text to reference configuration system and new config subcommands
- Updated shell setup instructions to include `config` in command detection

### Improved
- User customization without modifying the script
- Flexibility for different editor preferences and workflows
- Support for automated workflows (no prompts when configured)
- Better documentation with configuration examples

## [2.0.0] - 2026-01-16

### Added
- Skill-specific versioning system with semantic versioning
- `--version` flag to display current version
- Version number embedded in wt script header
- Comprehensive release metadata structure in `releases/` directory
- GitHub-style tagging convention for skill releases (`git-worktree-tool/v2.0.0`)

### Changed
- **BREAKING**: Moved to dedicated repository structure (skills-workshop)
- Enhanced documentation with version tracking and changelog references
- Improved help output to include version information
- Refactored release process to use manual version management

### Fixed
- Clarified versioning approach for future skill additions to the repository

## [1.0.0] - Pre-repository

### Added
- Initial release of git-worktree-tool
- Core `wt` script with complete git worktree management functionality
- Comprehensive documentation (SKILL.md, INSTALL.md, PLAN.md)
- Full feature set for simplified git worktree operations
