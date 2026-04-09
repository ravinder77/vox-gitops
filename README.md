# vox-gitops

GitOps repo for the Vox project on EKS.

## Structure

- `argocd/bootstrap/`: root Argo CD bootstrap application
- `argocd/apps/`: Argo CD applications and the `vox` AppProject
- `platform/gateway/`: shared Gateway API and AWS ALB resources
- `platform/security/`: IRSA service accounts, External Secrets, and network policies
- `helm/backend/`: backend workload chart
- `helm/frontend/`: frontend workload chart
- `ansible/`: operator and node bootstrap playbooks
- `scripts/`: bootstrap, validation, and teardown helpers

## Deployment Flow

1. Apply [`argocd/bootstrap/root-app.yaml`](/Users/ravinder/Projects/vox-gitops/argocd/bootstrap/root-app.yaml).
2. Argo syncs [`argocd/apps`](/Users/ravinder/Projects/vox-gitops/argocd/apps).
3. Shared controllers and platform resources deploy first.
4. Backend and frontend charts deploy into the `vox` namespace.

## Notes

- Workloads are expected to run in the `vox` namespace.
- `platform/security/` is wired to the active Argo `security` application and uses recursive directory sync.
- Placeholder values like `AWS_ACCOUNT_ID` still need to be replaced with real environment-specific values before production use.
- Run [`scripts/validate-manifests.sh`](/Users/ravinder/Projects/vox-gitops/scripts/validate-manifests.sh) before pushing manifest changes.
