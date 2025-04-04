#!/usr/bin/env bash

set -euo pipefail

# Requirements:
# - aws cli
# - package.sh script (for building handlers)

# If the user doesn't have requirements, exit early.
if ! command -v aws &>/dev/null; then
  echo "aws cli could not be found, aws cli is required to push handlers to S3." >&2
  exit 1
fi

# If a user doesn't supply required arguments,
# print the usage and exit.
if [ $# -ne 5 ]; then
  echo "Usage: $0 <bucket_name> <s3_key> <src_path> <package_path>" >&2
  exit 1
fi

BUCKET_NAME="${1:?Error: BUCKET_NAME is required}"
S3_KEY="${2:?Error: S3_KEY is required}"
SRC_PATH="${3:?Error: SRC_PATH is required}"
PACKAGE_SCRIPT="${4:?Error: PACKAGE_SCRIPT is required}"
PACKAGE_PATH="${5:?Error: PACKAGE_PATH is required}"

# Package the handler using package.sh
"$PACKAGE_SCRIPT" "$SRC_PATH" "$PACKAGE_PATH"

# Upload to S3 with versioning
aws s3api put-object \
  --bucket "$BUCKET_NAME" \
  --key "$S3_KEY" \
  --body "$PACKAGE_PATH"

# Clean up temporary package
rm -f "$PACKAGE_PATH"
