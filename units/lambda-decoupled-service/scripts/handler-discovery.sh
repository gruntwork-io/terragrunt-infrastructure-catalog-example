#!/usr/bin/env bash

set -euo pipefail

# Requirements:
# - aws cli

# If the user doesn't have requirements, exit early.
if ! command -v aws &> /dev/null; then
  echo "aws cli could not be found, aws cli is required to get the latest handler version." >&2
  exit 1
fi

# If a user doesn't supply required arguments,
# print the usage and exit.
if [ $# -ne 2 ]; then
  echo "Usage: $0 <bucket_name> <s3_key>" >&2
  exit 1
fi

BUCKET_NAME="${1:?Error: BUCKET_NAME is required}"
S3_KEY="${2:?Error: S3_KEY is required}"

# Get the latest version ID of the object
aws s3api head-object \
  --bucket "$BUCKET_NAME" \
  --key "$S3_KEY" \
  --query 'VersionId' \
  | tr -d '"'
