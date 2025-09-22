#!/bin/bash

set -euo pipefail

# Create commit and pull request for spec-kit sync

SPEC_KIT_TAG="${1:-}"
SYNC_BRANCH="${2:-}"

if [ -z "${SPEC_KIT_TAG}" ]; then
    echo "::error::SPEC_KIT_TAG is empty. Cannot create commit."
    exit 1
fi

if [ -z "${SYNC_BRANCH}" ]; then
    echo "::error::SYNC_BRANCH is empty. Cannot create branch."
    exit 1
fi

# Detect staged, unstaged, and untracked changes
if git diff --quiet && git diff --cached --quiet && [ -z "$(git ls-files --others --exclude-standard)" ]; then
    echo "No changes detected after sync. Skipping commit and PR creation."
    exit 0
fi

echo "Changes detected, proceeding with commit and PR creation..."

# Configure git user for GitHub Actions
git config user.name "github-actions[bot]"
git config user.email "41898282+github-actions[bot]@users.noreply.github.com"

# Create or reset local branch to current HEAD
echo "Creating/switching to branch: ${SYNC_BRANCH}"
git switch -C "${SYNC_BRANCH}"

# Stage all changes
git add -A

# Create commit
echo "Creating commit for spec-kit ${SPEC_KIT_TAG}"
git commit -m "chore: sync spec-kit ${SPEC_KIT_TAG}"

# Push branch to remote
echo "Pushing branch to remote..."
git push --set-upstream origin "${SYNC_BRANCH}"

# Check if PR already exists and create if not
if gh pr view --repo "${GITHUB_REPOSITORY}" --head "${SYNC_BRANCH}" >/dev/null 2>&1; then
    echo "Pull request for ${SYNC_BRANCH} already exists."
    PR_URL=$(gh pr view --repo "${GITHUB_REPOSITORY}" --head "${SYNC_BRANCH}" --json url --jq '.url')
    echo "Existing PR: ${PR_URL}"
else
    echo "Creating new pull request..."
    gh pr create \
        --title "chore: sync spec-kit ${SPEC_KIT_TAG}" \
        --body "Automated sync of Spec Kit release **${SPEC_KIT_TAG}**." \
        --base main \
        --head "${SYNC_BRANCH}"
    
    PR_URL=$(gh pr view --repo "${GITHUB_REPOSITORY}" --head "${SYNC_BRANCH}" --json url --jq '.url')
    echo "Created PR: ${PR_URL}"
fi