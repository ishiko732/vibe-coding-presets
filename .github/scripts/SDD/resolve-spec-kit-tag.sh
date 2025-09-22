#!/bin/bash

set -euo pipefail

# Resolve Spec Kit tag from multiple sources
# Priority: 1) workflow_dispatch input, 2) repository variable, 3) latest release

DISPATCH_SPEC_KIT_TAG="${1:-}"
VAR_SPEC_KIT_TAG="${2:-}"

if [ -n "${DISPATCH_SPEC_KIT_TAG}" ]; then
    TAG="${DISPATCH_SPEC_KIT_TAG}"
    echo "Using tag from workflow dispatch input: ${TAG}"
elif [ -n "${VAR_SPEC_KIT_TAG}" ]; then
    TAG="${VAR_SPEC_KIT_TAG}"
    echo "Using tag from repository variable: ${TAG}"
else
    echo "No tag provided, fetching latest release..."
    if command -v gh >/dev/null 2>&1; then
        TAG=$(gh release list --repo github/spec-kit --limit 1 --json tagName --jq '.[0].tagName')
        if [ -n "${TAG}" ] && [ "${TAG}" != "null" ]; then
            echo "Using latest release tag: ${TAG}"
        else
            echo "::error::Failed to fetch latest release tag from github/spec-kit"
            exit 1
        fi
    else
        echo "::error::GitHub CLI (gh) not available and no SPEC_KIT_TAG provided"
        echo "Provide the Spec Kit release tag through workflow dispatch input or repository variable"
        exit 1
    fi
fi

# Validate tag format
if [[ ! "${TAG}" =~ ^v[0-9]{4}\.[0-9]{2}\.[0-9]{2}$ ]]; then
    echo "::warning::Tag '${TAG}' does not match expected format (vYYYY.MM.DD)"
fi

# Generate safe branch name
SAFE_TAG=$(echo "${TAG}" | sed -e 's/[^A-Za-z0-9._-]/-/g')
SYNC_BRANCH="spec-kit/sync-${SAFE_TAG}"

# Output environment variables
echo "SPEC_KIT_TAG=${TAG}" >> "${GITHUB_ENV}"
echo "SYNC_BRANCH=${SYNC_BRANCH}" >> "${GITHUB_ENV}"

echo "Resolved tag: ${TAG}"
echo "Sync branch: ${SYNC_BRANCH}"