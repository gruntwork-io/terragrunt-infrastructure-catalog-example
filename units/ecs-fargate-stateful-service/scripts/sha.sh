#!/usr/bin/env bash

set -euo pipefail

# If the arguments are not provided, print the usage
if [ $# -ne 1 ]; then
    echo "Usage: $0 <SRC_PATH>" >&2
    exit 1
fi

SRC_PATH="${1:?SRC_PATH is required}"

# Hash only relative paths and file contents. The push hook and the image tag
# hash different copies of the source (the module working directory in the
# Terragrunt cache and the generated stack unit). Their timestamps, owners, and
# modes differ, and Terragrunt writes a different manifest file into each copy.
cd "${SRC_PATH}"
find . -type f ! -name '.terragrunt-*-manifest' -print0 | LC_ALL=C sort -z | xargs -0 sha256sum | sha256sum | awk '{print $1}'
