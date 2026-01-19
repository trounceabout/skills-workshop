# Contributing to Skills Workshop

Thank you for your interest in contributing to the Skills Workshop repository! This document provides guidelines for contributing.

## How to Report Bugs

1. **Check existing issues** - Search the issue tracker to see if your bug has already been reported
2. **Create a new issue** - If not found, create a new issue with:
   - A clear, descriptive title
   - Steps to reproduce the bug
   - Expected vs actual behavior
   - Your environment (OS, shell version, etc.)

## How to Suggest Features

1. **Open an issue** with the `enhancement` label
2. Describe the feature and its use case
3. Explain why this would benefit other users

## Adding a New Skill

Skills are self-contained tools or guides in this repository. To add a new skill:

### Directory Structure

```
your-skill-name/
  SKILL.md       # Required: Skill documentation with YAML frontmatter
  INSTALL.md     # Required: Installation instructions
  your-script    # Optional: Executable script (if your skill includes a tool)
  PLAN.md        # Optional: Development planning notes
```

### Required Files

1. **SKILL.md** - Must include YAML frontmatter:
   ```yaml
   ---
   name: Your Skill Name
   version: 1.0.0
   description: Brief description of what the skill does
   author: Your Name
   ---
   ```

2. **INSTALL.md** - Clear installation steps users can follow

### Optional Files

3. **Main script** - If your skill includes a tool, add an executable (typically a bash script)

### Skill Guidelines

- Skills can be documentation-only (guides) or include executable tools
- If including scripts, they should be POSIX-compliant or clearly document shell requirements
- Include `--help` and `--version` flags for any executables
- Use meaningful exit codes (0 = success, non-zero = error)
- Handle errors gracefully with helpful messages

## Code Style Guidelines

### Bash Scripts

- Use `set -euo pipefail` at the top of scripts
- Quote all variable expansions: `"$variable"` not `$variable`
- Use `[[` for conditionals in bash (not `[`)
- Add comments for non-obvious logic
- Use lowercase for local variables, UPPERCASE for exported/config variables
- Run `shellcheck` before submitting (no warnings)

### Naming Conventions

- Directories: `kebab-case`
- Scripts: `lowercase` (no extension for executables)
- Functions: `snake_case`

## Pull Request Process

1. **Fork the repository** and create a feature branch
2. **Make your changes** following the code style guidelines
3. **Test your changes** thoroughly
4. **Run linting** - `shellcheck` for bash scripts
5. **Commit with clear messages** following conventional commits:
   - `feat:` for new features
   - `fix:` for bug fixes
   - `docs:` for documentation changes
   - `chore:` for maintenance tasks
6. **Open a pull request** with:
   - Clear description of changes
   - Link to related issues
   - Screenshots/examples if applicable

## Version Bump Process

When releasing a new version:

1. Update the `VERSION` variable in the main script (if applicable)
2. Update `CHANGELOG.md` with changes
3. Update version in `SKILL.md` frontmatter
4. Create a git tag: `git tag -a v1.2.3 -m "Version 1.2.3"`

## Questions?

Open an issue with the `question` label and we'll help you out!
