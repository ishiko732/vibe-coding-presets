#!/bin/bash

set -euo pipefail

# Extract and sync Spec Kit content using overlay method instead of rm -rf

# Get archive path from parameter or environment variable
if [ -n "${1:-}" ]; then
    ARCHIVE_PATH="${1}"
elif [ -n "${ARCHIVE_PATH:-}" ]; then
    # ARCHIVE_PATH already set as environment variable
    ARCHIVE_PATH="${ARCHIVE_PATH}"
else
    echo "::error::No archive path provided"
    echo "Expected archive file path as first parameter or ARCHIVE_PATH environment variable"
    exit 1
fi

if [ ! -f "${ARCHIVE_PATH}" ]; then
    echo "::error::Spec Kit archive was not found at: ${ARCHIVE_PATH}"
    exit 1
fi

# Create temporary working directory
WORKDIR=$(mktemp -d)
echo "Using temporary directory: ${WORKDIR}"

# Extract archive
echo "Extracting ${ARCHIVE_PATH}..."
if ! unzip -q "${ARCHIVE_PATH}" -d "${WORKDIR}"; then
    echo "::error::Failed to extract archive ${ARCHIVE_PATH}"
    rm -rf "${WORKDIR}"
    exit 1
fi

# Verify expected directories exist in extracted content
if [ ! -d "${WORKDIR}/.claude" ]; then
    echo "::error::Expected .claude directory was not found in the archive"
    echo "Archive contents:"
    ls -la "${WORKDIR}" || true
    rm -rf "${WORKDIR}"
    exit 1
fi

# Check for .specif or .specify directory (name may vary)
SPECIF_DIR=""
if [ -d "${WORKDIR}/.specif" ]; then
    SPECIF_DIR=".specif"
elif [ -d "${WORKDIR}/.specify" ]; then
    SPECIF_DIR=".specify"
else
    echo "::error::Expected .specif or .specify directory was not found in the archive"
    echo "Archive contents:"
    ls -la "${WORKDIR}" || true
    rm -rf "${WORKDIR}"
    exit 1
fi

echo "Archive extracted successfully, found .claude and ${SPECIF_DIR} directories"

# Sync content using overlay method instead of rm -rf
# This preserves existing content and overlays new content

echo "Syncing .claude directory to .claude/commands/SDD/ ..."
# Create target directories if they don't exist
mkdir -p ".claude/commands/SDD"

# Sync commands to SDD subdirectory
if [ -d "${WORKDIR}/.claude/commands" ]; then
    rsync -av "${WORKDIR}/.claude/commands/" ".claude/commands/SDD/"
fi

# Sync other .claude content (excluding commands) to preserve existing structure
if [ -d "${WORKDIR}/.claude" ]; then
    # Use rsync with exclude to avoid duplicating commands
    rsync -av --exclude="commands/" "${WORKDIR}/.claude/" ".claude/"
fi

echo "Syncing ${SPECIF_DIR} directory..."
# Determine target directory name (handle both .specif and .specify)
TARGET_SPECIF_DIR="${SPECIF_DIR}"
if [ -d ".specify" ] && [ "${SPECIF_DIR}" = ".specif" ]; then
    # If we have .specify locally but source is .specif, sync to .specify
    TARGET_SPECIF_DIR=".specify"
fi

# Create target directories
mkdir -p "${TARGET_SPECIF_DIR}"

# Sync all content from specif/specify directory (including scripts)
if [ -d "${WORKDIR}/${SPECIF_DIR}" ]; then
    rsync -av "${WORKDIR}/${SPECIF_DIR}/" "${TARGET_SPECIF_DIR}/"
fi

# Output environment variable for cleanup
if [ -n "${GITHUB_ENV:-}" ]; then
    echo "TEMP_WORKDIR=${WORKDIR}" >> "${GITHUB_ENV}"
else
    echo "TEMP_WORKDIR=${WORKDIR}"
fi

echo "Content sync completed successfully"