#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "Checking for unresolved deployment placeholders"
bash "${ROOT_DIR}/scripts/check-placeholders.sh"

echo "Linting Helm charts"
for chart_dir in "${ROOT_DIR}"/helm/*; do
  [[ -d "${chart_dir}" ]] || continue
  helm lint "${chart_dir}"
done

echo "Rendering Helm charts"
declare -A chart_namespaces=(
  [backend]="vox"
  [frontend]="vox"
)

for chart_dir in "${ROOT_DIR}"/helm/*; do
  [[ -d "${chart_dir}" ]] || continue
  chart_name="$(basename "${chart_dir}")"
  namespace="${chart_namespaces[${chart_name}]:-${chart_name}}"
  helm template "${chart_name}" "${chart_dir}" \
    --namespace "${namespace}" >/tmp/"${chart_name}"-rendered.yaml
done

if kubectl version --request-timeout=1s >/dev/null 2>&1; then
  echo "Client-validating local manifests"
  kubectl apply --dry-run=client --validate=false -f "${ROOT_DIR}/argocd/apps" >/dev/null
  kubectl apply --dry-run=client --validate=false -f "${ROOT_DIR}/argocd/project/vox-project.yaml" >/dev/null
  kubectl apply --dry-run=client --validate=false -f "${ROOT_DIR}/argocd/bootstrap/root-app.yaml" >/dev/null
  kubectl apply --dry-run=client --validate=false -f "${ROOT_DIR}/platform/gateway" >/dev/null
  kubectl apply --dry-run=client --validate=false -f "${ROOT_DIR}/platform/policies" >/dev/null
  kubectl apply --dry-run=client --validate=false -f "${ROOT_DIR}/platform/security" >/dev/null
else
  echo "Skipping kubectl dry-run validation because no cluster API is reachable"
fi

echo "Validation complete"
