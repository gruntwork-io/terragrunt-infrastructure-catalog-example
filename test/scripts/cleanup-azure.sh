#!/usr/bin/env bash
#
# Deletes the Azure resource groups that the Azure tests left behind.
#
# Every Azure test puts its resources in a resource group named with the `tgcattest` prefix, and destroys it when the
# test finishes. A crashed or cancelled run can still leave some behind. This script finds those resource groups and
# deletes them. It skips resource groups younger than the cutoff, so it never touches a test that is still running.
#
# Usage:
#   test/scripts/cleanup-azure.sh [--delete] [--prefix <prefix>] [--older-than-hours <hours>]
#
# Without --delete, the script only lists what it would delete.
# The subscription comes from ARM_SUBSCRIPTION_ID, or the Azure CLI's current subscription when that isn't set.

set -euo pipefail

prefix="tgcattest"
older_than_hours=3
delete=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --delete)
      delete=true
      shift
      ;;
    --prefix)
      prefix="$2"
      shift 2
      ;;
    --older-than-hours)
      older_than_hours="$2"
      shift 2
      ;;
    *)
      echo "Unknown argument: $1" >&2
      exit 1
      ;;
  esac
done

subscription_id="${ARM_SUBSCRIPTION_ID:-$(az account show --query id --output tsv)}"

# GNU date (Linux) and BSD date (macOS) take the offset differently.
cutoff="$(date -u -d "-${older_than_hours} hours" +%Y-%m-%dT%H:%M:%SZ 2>/dev/null ||
  date -u -v-"${older_than_hours}"H +%Y-%m-%dT%H:%M:%SZ)"

# `az group list` doesn't return creation times, so ask the ARM API for them directly.
# ISO 8601 UTC timestamps sort as strings, so a string comparison against the cutoff works.
resource_groups="$(az rest --method get \
  --url "https://management.azure.com/subscriptions/${subscription_id}/resourcegroups?api-version=2021-04-01&\$expand=createdTime" \
  --query "value[?starts_with(name, '${prefix}') && createdTime < '${cutoff}'].name" \
  --output tsv)"

if [[ -z "$resource_groups" ]]; then
  echo "No resource groups starting with '${prefix}' created before ${cutoff}."
  exit 0
fi

while IFS= read -r resource_group; do
  if [[ "$delete" == true ]]; then
    echo "Deleting ${resource_group}"
    az group delete --subscription "$subscription_id" --name "$resource_group" --yes --no-wait
  else
    echo "Would delete ${resource_group} (re-run with --delete to delete it)"
  fi
done <<<"$resource_groups"
