#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "Linting Helm charts"
helm lint "${ROOT_DIR}/helm/backend"
helm lint "${ROOT_DIR}/helm/frontend"

echo "Rendering Helm charts"
helm template vox-backend "${ROOT_DIR}/helm/backend" --namespace vox >/tmp/vox-backend-rendered.yaml
helm template vox-frontend "${ROOT_DIR}/helm/frontend" --namespace vox >/tmp/vox-frontend-rendered.yaml

if kubectl version --request-timeout=1s >/dev/null 2>&1; then
  echo "Client-validating local manifests"
  kubectl apply --dry-run=client --validate=false -f "${ROOT_DIR}/argocd/project/vox-project.yaml" >/dev/null
  kubectl apply --dry-run=client --validate=false -f "${ROOT_DIR}/argocd/bootstrap/root-app.yaml" >/dev/null
  kubectl apply --dry-run=client --validate=false -f "${ROOT_DIR}/platform/gateway" >/dev/null
  kubectl apply --dry-run=client --validate=false -f "${ROOT_DIR}/platform/security" >/dev/null
else
  echo "Skipping kubectl dry-run validation because no cluster API is reachable"
fi

echo "Validation complete"
