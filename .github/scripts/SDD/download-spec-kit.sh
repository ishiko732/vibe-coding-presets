#!/bin/bash

set -euo pipefail

# Download Spec Kit release assets

SPEC_KIT_TAG="${1:-}"

if [ -z "${SPEC_KIT_TAG}" ]; then
    echo "::error::SPEC_KIT_TAG is empty. Cannot download release assets."
    exit 1
fi

# Construct asset filename
asset="spec-kit-template-claude-sh-${SPEC_KIT_TAG}.zip"

echo "Fetching ${asset} from github/spec-kit@${SPEC_KIT_TAG}"

# Download the release asset
if ! gh release download "${SPEC_KIT_TAG}" \
    --repo github/spec-kit \
    --pattern "${asset}" \
    --output "${asset}"; then
    echo "::error::Failed to download ${asset} for release ${SPEC_KIT_TAG}"
    echo "Please verify that the tag and asset exist in the github/spec-kit repository"
    exit 1
fi

# Verify file was downloaded
if [ ! -f "${asset}" ]; then
    echo "::error::Asset file ${asset} was not found after download"
    exit 1
fi

# Output environment variable
echo "ARCHIVE_PATH=${asset}" >> "${GITHUB_ENV}"

echo "Successfully downloaded: ${asset}"