#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

declare -a checks=(
  "AWS_ACCOUNT_ID|Replace AWS account placeholders before deploying."
  "your-webhook|Replace the example Slack webhook before deploying."
  "vox\\.example\\.com|Replace example frontend domain before deploying."
  "api\\.vox\\.example\\.com|Replace example API domain before deploying."
  "123456789012:certificate/xxxx|Replace the example ACM certificate ARN before deploying."
)

search_paths=(
  "${ROOT_DIR}/argocd"
  "${ROOT_DIR}/helm"
  "${ROOT_DIR}/platform"
  "${ROOT_DIR}/Makefile"
)

failures=0

for check in "${checks[@]}"; do
  pattern="${check%%|*}"
  message="${check#*|}"

  if matches="$(grep -RInE "${pattern}" "${search_paths[@]}" 2>/dev/null)"; then
    echo "Placeholder check failed: ${message}"
    echo "${matches}"
    echo
    failures=1
  fi
done

if [[ "${failures}" -ne 0 ]]; then
  exit 1
fi

echo "No deployment placeholders detected"
