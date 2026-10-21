#!/usr/bin/env bash

set -euo pipefail

# Requirements:
# - zip

# If the user doesn't have requirements, exit early.
if ! command -v zip &> /dev/null; then
  echo "zip could not be found, zip is required to package the lambda function." >&2
  exit 1
fi

# If a user doesn't supply required arguments,
# print the usage and exit.
if [ $# -ne 2 ]; then
  echo "Usage: $0 <src_path> <package_path>" >&2
  exit 1
fi

SRC_PATH="${1:?Error: SRC_PATH is required}"
PACKAGE_PATH="${2:?Error: PACKAGE_PATH is required}"

# Package the lambda function.
pushd "$SRC_PATH" > /dev/null

zip -r "$PACKAGE_PATH" .
