#!/usr/bin/env bash

set -euo pipefail

# If the arguments are not provided, print the usage
if [ $# -ne 1 ]; then
    echo "Usage: $0 <SRC_PATH>" >&2
    exit 1
fi

SRC_PATH="${1:?SRC_PATH is required}"

tar cvf - "${SRC_PATH}" 2>/dev/null | sha256sum | awk '{print $1}'
