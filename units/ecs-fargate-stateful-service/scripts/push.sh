#!/usr/bin/env bash

set -euo pipefail

# If the arguments are not provided, print the usage
if [ $# -ne 2 ]; then
    echo "Usage: $0 <SRC_PATH> <REPO_URL>" >&2
    exit 1
fi

SRC_PATH="${1:?SRC_PATH is required}"
REPO_URL="${2:?REPO_URL is required}"

REPO_NAME="$(cut -d/ -f2 <<< "${REPO_URL}")"

# Check to see if the repository exists
if ! aws ecr describe-repositories --repository-names "${REPO_NAME}" > /dev/null 2>&1; then
    echo "Repository ${REPO_NAME} does not exist, exiting..." >&2
    exit 0
fi

# Get the directory of the script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Get the SHA of the source path
TAG_SHA="$("$SCRIPT_DIR/sha.sh" "$SRC_PATH")"

# Check if the image tag already exists
if aws ecr describe-images --repository-name "${REPO_NAME}" --image-ids imageTag="${TAG_SHA}" > /dev/null 2>&1; then
    echo "Image ${REPO_URL}:${TAG_SHA} already exists, skipping..." >&2
    exit 0
fi

IMAGE_TAG="${REPO_URL}:${TAG_SHA}"

AWS_ACCOUNT_ID="$(cut -d. -f1 <<< "${REPO_URL}")"
AWS_REGION="$(cut -d. -f4 <<< "${REPO_URL}")"

aws ecr get-login-password --region "${AWS_REGION}" | docker login --username AWS --password-stdin "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

# Build with buildx and push to the repository
docker buildx \
    build \
    --platform linux/arm64 \
    --push \
    -t "${IMAGE_TAG}" \
    "${SRC_PATH}"
