#!/usr/bin/env bash

set -euo pipefail

ENVIRONMENT="${1:-dev}"
shift $(( $# > 0 ? 1 : 0 ))

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_DIR="${SCRIPT_DIR}/../environments/${ENVIRONMENT}"

if [[ ! -d "${ENV_DIR}" ]]; then
  echo "Unknown environment: ${ENVIRONMENT}" >&2
  exit 1
fi

terraform -chdir="${ENV_DIR}" plan "$@"
