#!/usr/bin/env bash

set -euo pipefail

namespace="${1:-vox}"

kubectl annotate externalsecret -n "${namespace}" --all \
  force-sync="$(date -u +%Y-%m-%dT%H:%M:%SZ)" --overwrite
