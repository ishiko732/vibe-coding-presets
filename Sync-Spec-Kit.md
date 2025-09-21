# Sync Spec-Kit Commands

## Overview

This document describes how to synchronize commands from GitHub's [spec-kit repository](https://github.com/github/spec-kit/tree/main/templates/commands) to the local `.claude/commands/SDD` directory.

## Directory Structure

```
.claude/
├── commands/
│   ├── SDD/                 # Software Design Documents commands
│   └── init/               # Initialization commands
├── agents/                 # Agent configurations
└── output-styles/          # Output style templates
```

## Synchronization Methods

### Method 1: Manual Git Subtree (Recommended)

Add the spec-kit repository as a subtree and sync specific directories:

```bash
# Add spec-kit as a remote
git remote add spec-kit https://github.com/github/spec-kit.git

# Add the templates/commands directory as a subtree
git subtree add --prefix=.claude/commands/SDD spec-kit main --squash

# To update later
git subtree pull --prefix=.claude/commands/SDD spec-kit main --squash
```

### Method 2: Automated Sync Script

Create a sync script to automatically download and update commands:

```bash
#!/bin/bash
# sync-spec-kit.sh

SPEC_KIT_URL="https://github.com/github/spec-kit"
TARGET_DIR=".claude/commands/SDD"
TEMP_DIR="/tmp/spec-kit-sync"

# Clean and create temp directory
rm -rf "$TEMP_DIR"
mkdir -p "$TEMP_DIR"

# Clone spec-kit repository
git clone --depth 1 "$SPEC_KIT_URL" "$TEMP_DIR"

# Create target directory if it doesn't exist
mkdir -p "$TARGET_DIR"

# Sync commands from templates/commands
if [ -d "$TEMP_DIR/templates/commands" ]; then
    rsync -av --delete "$TEMP_DIR/templates/commands/" "$TARGET_DIR/"
    echo "✅ Successfully synced spec-kit commands to $TARGET_DIR"
else
    echo "❌ templates/commands directory not found in spec-kit"
    exit 1
fi

# Cleanup
rm -rf "$TEMP_DIR"

echo "🔄 Sync completed"
```

### Method 3: GitHub API Approach

Use GitHub API to fetch and sync specific files:

```bash
#!/bin/bash
# api-sync-spec-kit.sh

API_URL="https://api.github.com/repos/github/spec-kit/contents/templates/commands"
TARGET_DIR=".claude/commands/SDD"

# Create target directory
mkdir -p "$TARGET_DIR"

# Fetch directory contents via API
curl -s "$API_URL" | jq -r '.[] | select(.type=="file") | .download_url' | while read -r url; do
    filename=$(basename "$url")
    echo "Downloading $filename..."
    curl -s "$url" -o "$TARGET_DIR/$filename"
done

echo "✅ API sync completed"
```

## Sync Automation Options

### 1. GitHub Actions Workflow

Create `.github/workflows/sync-spec-kit.yml`:

```yaml
name: Sync Spec-Kit Commands

on:
  schedule:
    - cron: '0 0 * * 1'  # Weekly on Monday
  workflow_dispatch:     # Manual trigger

jobs:
  sync:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Sync spec-kit commands
        run: |
          chmod +x ./sync-spec-kit.sh
          ./sync-spec-kit.sh
          
      - name: Commit changes
        run: |
          git config --local user.email "action@github.com"
          git config --local user.name "GitHub Action"
          git add .claude/commands/SDD/
          git commit -m "chore: sync spec-kit commands" || exit 0
          git push
```

### 2. Pre-commit Hook

Add to `.git/hooks/pre-commit`:

```bash
#!/bin/bash
# Check if spec-kit commands need updating
if [ -f "./sync-spec-kit.sh" ]; then
    echo "🔄 Checking spec-kit commands..."
    ./sync-spec-kit.sh --check-only
fi
```

## Usage Instructions

### Initial Setup

1. Choose your preferred sync method (Method 1 recommended)
2. Run the initial sync command
3. Verify commands are properly copied to `.claude/commands/SDD/`
4. Test commands in Claude Code

### Regular Updates

- **Manual**: Run sync script when needed
- **Automated**: Set up GitHub Actions or cron job
- **On-demand**: Use `git subtree pull` for Method 1

## Command Structure

Expected structure after sync:

```
.claude/commands/SDD/
├── architecture.md         # Architecture documentation command
├── api-design.md          # API design specification command  
├── requirements.md        # Requirements gathering command
├── technical-spec.md      # Technical specification command
└── ...                    # Other spec-kit commands
```

## Troubleshooting

### Common Issues

1. **Permission denied**: Ensure script has execute permissions (`chmod +x`)
2. **Network issues**: Check internet connection and GitHub access
3. **Merge conflicts**: Resolve manually or use `--squash` option
4. **Missing dependencies**: Install required tools (`git`, `rsync`, `curl`, `jq`)

### Verification Commands

```bash
# Check if commands exist
ls -la .claude/commands/SDD/

# Verify command content
head -n 10 .claude/commands/SDD/*.md

# Test Claude Code command loading
claude --help | grep -i sdd
```

## Best Practices

1. **Backup**: Always backup existing commands before sync
2. **Testing**: Test commands after sync before committing
3. **Selective sync**: Only sync commands you need
4. **Version control**: Track changes with meaningful commit messages
5. **Documentation**: Keep this sync documentation updated

## Security Considerations

- Verify command content before execution
- Use trusted sources only (official GitHub repositories)
- Review permissions and access requirements
- Monitor for unexpected changes in synced content

## Maintenance

- Update sync scripts when spec-kit structure changes
- Monitor spec-kit repository for breaking changes
- Regularly test automated sync processes
- Keep sync documentation current