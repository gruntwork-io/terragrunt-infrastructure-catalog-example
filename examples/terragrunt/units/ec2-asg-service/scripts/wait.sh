#!/usr/bin/env bash

set -euo pipefail

# Requirements:
# - curl

# If the user doesn't have requirements, just exit with a zero to avoid a hard requirement here.
if ! command -v curl &> /dev/null; then
  echo "curl could not be found, skipping wait to avoid failure." >&2
  exit 0
fi

# Wait for the service to start.
# Expected time to start: 15 seconds.
# We check the health check endpoint every 1 seconds.
# We wait for a maximum of 30 seconds.

# Get the URL of the service.
url=$("$TG_CTX_TF_PATH" output -raw url)

# Wait for the service to start.
for i in {1..30}; do
  if curl -s -o /dev/null -w "%{http_code}" "$url" | grep -q "200"; then
    echo "Service started successfully" >&2
    exit 0
  fi

  echo "Waiting for the service to start..." >&2
  echo "Attempt $i of 30" >&2
  sleep 1
done

echo "Service failed to start" >&2
exit 1
