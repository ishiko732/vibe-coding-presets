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

# Check if remote branch already exists
echo "Checking if remote branch ${SYNC_BRANCH} exists..."
if git ls-remote --exit-code --heads origin "${SYNC_BRANCH}" >/dev/null 2>&1; then
    echo "Remote branch ${SYNC_BRANCH} already exists"
    
    # Check if PR already exists first
    if gh pr view --repo "${GITHUB_REPOSITORY}" --head "${SYNC_BRANCH}" >/dev/null 2>&1; then
        echo "Pull request for ${SYNC_BRANCH} already exists. Skipping creation."
        PR_URL=$(gh pr view --repo "${GITHUB_REPOSITORY}" --head "${SYNC_BRANCH}" --json url --jq '.url')
        echo "Existing PR: ${PR_URL}"
        exit 0
    fi
    
    # Fetch the remote branch
    echo "Fetching remote branch..."
    git fetch origin "${SYNC_BRANCH}"
    
    # Save current changes by stashing them
    STASHED=false
    if [[ -n "$(git status --porcelain)" ]]; then
        echo "Stashing current changes..."
        git stash push -u -m "temp stash for branch switch"
        STASHED=true
    fi
    
    # Create local branch from remote
    echo "Switching to branch ${SYNC_BRANCH}..."
    git switch -C "${SYNC_BRANCH}" "origin/${SYNC_BRANCH}"
    
    # Apply stashed changes
    if [ "$STASHED" = true ]; then
        echo "Applying stashed changes..."
        git stash pop
    fi
    
    # Stage all changes
    echo "Staging changes..."
    git add -A
    
    # Check if there are any changes to commit
    if git diff --cached --quiet; then
        echo "No new changes to commit. Branch is already up to date."
        exit 0
    fi
    
    # Create commit
    echo "Creating commit for spec-kit ${SPEC_KIT_TAG}"
    git commit -m "chore: sync spec-kit ${SPEC_KIT_TAG}"
    
    # Push changes
    echo "Pushing changes to existing branch..."
    git push origin "${SYNC_BRANCH}"
else
    echo "Remote branch ${SYNC_BRANCH} does not exist, creating new branch"
    
    # Create or reset local branch to current HEAD
    echo "Creating/switching to branch: ${SYNC_BRANCH}"
    git switch -C "${SYNC_BRANCH}"
    
    # Stage all changes
    git add -A
    
    # Create commit
    echo "Creating commit for spec-kit ${SPEC_KIT_TAG}"
    git commit -m "chore: sync spec-kit ${SPEC_KIT_TAG}"
    
    # Push branch to remote
    echo "Pushing new branch to remote..."
    git push --set-upstream origin "${SYNC_BRANCH}"
fi

# Create PR for new branch (existing branch already handled above)
if ! gh pr view --repo "${GITHUB_REPOSITORY}" --head "${SYNC_BRANCH}" >/dev/null 2>&1; then
    echo "Creating new pull request..."
    gh pr create \
        --title "chore: sync spec-kit ${SPEC_KIT_TAG}" \
        --body "Automated sync of Spec Kit release **${SPEC_KIT_TAG}**." \
        --base main \
        --head "${SYNC_BRANCH}"
    
    PR_URL=$(gh pr view --repo "${GITHUB_REPOSITORY}" --head "${SYNC_BRANCH}" --json url --jq '.url')
    echo "Created PR: ${PR_URL}"
else
    PR_URL=$(gh pr view --repo "${GITHUB_REPOSITORY}" --head "${SYNC_BRANCH}" --json url --jq '.url')
    echo "Updated existing PR: ${PR_URL}"
fi