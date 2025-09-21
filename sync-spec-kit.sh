#!/bin/bash
# sync-spec-kit.sh - Sync spec-kit templates/commands to .claude/commands/SDD

set -e

SPEC_KIT_URL="https://github.com/github/spec-kit"
TARGET_DIR=".claude/commands/SDD"
TEMP_DIR="/tmp/spec-kit-sync"

echo "🔄 Starting spec-kit sync..."

# Clean and create temp directory
rm -rf "$TEMP_DIR"
mkdir -p "$TEMP_DIR"

# Clone spec-kit repository with sparse checkout
echo "📦 Cloning spec-kit repository..."
git clone --depth 1 --filter=blob:none --sparse "$SPEC_KIT_URL" "$TEMP_DIR"

# Configure sparse checkout to only get templates/commands
cd "$TEMP_DIR"
git sparse-checkout set templates/commands
git checkout

# Create target directory if it doesn't exist
cd - > /dev/null
mkdir -p "$TARGET_DIR"

# Sync commands from templates/commands
if [ -d "$TEMP_DIR/templates/commands" ]; then
    echo "📋 Syncing commands..."
    rsync -av --delete "$TEMP_DIR/templates/commands/" "$TARGET_DIR/"
    echo "✅ Successfully synced spec-kit commands to $TARGET_DIR"
    
    # List synced files
    echo "📄 Synced files:"
    ls -la "$TARGET_DIR"
else
    echo "❌ templates/commands directory not found in spec-kit"
    exit 1
fi

# Cleanup
rm -rf "$TEMP_DIR"

echo "🎉 Sync completed successfully!"