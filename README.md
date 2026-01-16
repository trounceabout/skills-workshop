# Skills Workshop

A curated collection of Claude Code skills for enhanced software engineering workflows.

## Repository Structure

```
skills-workshop/
├── git-worktree-tool/     # Skill code (user-facing)
│   ├── wt                 # Executable script for git worktree management
│   ├── SKILL.md           # Comprehensive skill documentation
│   ├── INSTALL.md         # Installation and setup instructions
│   └── PLAN.md            # Implementation planning guide
│
└── releases/              # Version metadata (repository-only)
    └── git-worktree-tool/
        ├── VERSION        # Current version number (2.0.0)
        └── CHANGELOG.md   # Version history and release notes
```

## Available Skills

### git-worktree-tool (v2.0.0)

**Simplified Git Worktree Management** - A comprehensive Claude Code skill and practical tool for managing git worktrees with ease.

- **What it does**: Provides an intuitive `wt` script that simplifies creating, switching, deleting, and managing git worktrees
- **Key features**: Easy worktree creation, VS Code integration, automated branch management, comprehensive guidance
- **Getting started**: See `git-worktree-tool/INSTALL.md` for setup
- **Documentation**: See `git-worktree-tool/SKILL.md` for full guide
- **Version**: 2.0.0 (see `releases/git-worktree-tool/CHANGELOG.md`)

Check version with: `wt --version` or `wt -v`

## Versioning

Each skill maintains independent semantic versioning using `MAJOR.MINOR.PATCH` format.

### Version File Locations

- **VERSION file**: Located in `releases/<skill-name>/VERSION` (repository only)
- **Embedded version**: Stored in the skill's executable/script
- **Changelog**: Located in `releases/<skill-name>/CHANGELOG.md`

### Why This Approach?

- **User-facing directories stay clean**: Users download only skill files they need
- **Release metadata organized**: All version tracking in dedicated `releases/` directory
- **Independent skill evolution**: Each skill versions separately
- **Clear release tracking**: GitHub tags follow pattern `<skill-name>/v<version>`

### Checking Skill Versions

For git-worktree-tool:
```bash
wt --version        # Shows embedded version in script
wt -v              # Alternative version flag
wt version         # Explicit version command
wt help            # Help text includes version (v2.0.0)
```

Repository version metadata:
```bash
cat releases/git-worktree-tool/VERSION      # Source of truth for version
cat releases/git-worktree-tool/CHANGELOG.md # Version history
```

## Release Process

### Creating a New Release

Manual versioning process:

1. **Update skill script**: Change embedded VERSION variable
   ```bash
   # In git-worktree-tool/wt, update:
   VERSION="2.1.0"
   ```

2. **Update release metadata**:
   ```bash
   # Update releases/git-worktree-tool/VERSION
   echo "2.1.0" > releases/git-worktree-tool/VERSION

   # Add entry to releases/git-worktree-tool/CHANGELOG.md
   ```

3. **Update skill documentation**:
   - Update version in skill's SKILL.md if present
   - Add any relevant release notes

4. **Commit changes**:
   ```bash
   git add git-worktree-tool/ releases/git-worktree-tool/
   git commit -m "Bump git-worktree-tool to v2.1.0"
   ```

5. **Create GitHub release tag**:
   ```bash
   git tag git-worktree-tool/v2.1.0
   git push origin git-worktree-tool/v2.1.0
   ```

### GitHub Release Tags

Tags follow the pattern: `<skill-name>/v<version>`

Examples:
- `git-worktree-tool/v2.0.0` - Initial release
- `git-worktree-tool/v2.0.1` - Patch release
- `git-worktree-tool/v2.1.0` - Minor release with new features

This allows GitHub to track releases per skill within the monorepo.

## Adding New Skills

### For Skill Contributors

To add a new skill to the workshop:

1. **Create skill directory**: `<skill-name>/`
   - Add your skill files (script, documentation, etc.)
   - Include embedded version in any executables: `VERSION="1.0.0"`

2. **Create release directory**: `releases/<skill-name>/`
   - Add `VERSION` file with initial version (e.g., `1.0.0`)
   - Add `CHANGELOG.md` documenting v1.0.0 as initial release

3. **Documentation**:
   - Create comprehensive `SKILL.md` with full usage guide
   - Create `INSTALL.md` with setup instructions
   - Reference version in SKILL.md's version section

4. **Update root README.md**:
   - Add skill to "Available Skills" section
   - Include version link to releases/CHANGELOG

5. **Create initial release**:
   - Commit all changes
   - Create tag: `<skill-name>/v1.0.0`
   - Push to GitHub

## Structure Details

### Skill Directories (User-Facing)

Located at `<skill-name>/`:
- Executable scripts or main files
- `SKILL.md` - Complete documentation and guidance
- `INSTALL.md` - Setup and installation
- `PLAN.md` - Implementation planning (optional)
- Version references in documentation point to `../releases/`

**What goes here**: Only files users need to install and use the skill.

**What doesn't go here**: VERSION files, CHANGELOG files (these belong in releases/).

### Releases Directory (Repository-Only)

Located at `releases/<skill-name>/`:
- `VERSION` - Current version number (plain text, single line)
- `CHANGELOG.md` - Complete version history following Keep a Changelog format

**What goes here**: All version metadata and release tracking.

**What doesn't go here**: Skill code or user-facing documentation.

## Contributing

To contribute improvements to existing skills or add new skills:

1. Fork the repository
2. Create a feature branch
3. Make your changes following the structure guidelines
4. Update version metadata as needed
5. Submit a pull request

## License

Each skill may have its own license. See individual skill directories for details.

## Version History

### Repository-Level

- **v1.0.0** (Jan 16, 2026) - Initial release with git-worktree-tool

### Skill Versions

**git-worktree-tool**: See `releases/git-worktree-tool/CHANGELOG.md`
