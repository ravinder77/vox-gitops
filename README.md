# vox-gitops

GitOps repo for the Vox project on EKS.

## Structure

- `argocd/bootstrap/`: root Argo CD bootstrap application
- `argocd/apps/`: Argo CD applications managed by the app-of-apps pattern
- `argocd/project/`: Argo CD AppProject definitions
- `platform/security/`: IRSA service accounts, External Secrets resources, and namespace bootstrap manifests
- `helm/backend/`: backend workload chart
- `helm/frontend/`: frontend workload chart
- `ansible/`: operator and node bootstrap playbooks
- `docs/`: production configuration notes and operator guidance
- `scripts/`: bootstrap, validation, and teardown helpers

## Deployment Flow

1. Install Argo CD from the repo-managed chart with `make argocd-install`.
2. Apply [`argocd/project/vox-project.yaml`](/Users/ravinder/Projects/vox-gitops/argocd/project/vox-project.yaml) and [`argocd/bootstrap/root-app.yaml`](/Users/ravinder/Projects/vox-gitops/argocd/bootstrap/root-app.yaml), or run `make bootstrap`.
3. Argo syncs [`argocd/apps`](/Users/ravinder/Projects/vox-gitops/argocd/apps).
4. Shared controllers and platform resources required by the application deploy first.
5. Backend and frontend charts deploy into the `vox` namespace.

## Notes

- Workloads are expected to run in the `vox` namespace.
- Gateway API is intentionally out of scope for the first EKS deployment path and can be added later as a separate platform layer.
- `argocd/apps/` includes remote Helm applications for External Secrets, monitoring, and Argo Rollouts in addition to repo-managed applications.
- `scripts/validate-manifests.sh` fails fast if production placeholders such as `AWS_ACCOUNT_ID`, example domains, or the sample Slack webhook are still present in deployable manifests.
- Required environment-specific values are documented in [`docs/production-configuration.md`](/Users/ravinder/Projects/vox-gitops/docs/production-configuration.md).
- Run [`scripts/validate-manifests.sh`](/Users/ravinder/Projects/vox-gitops/scripts/validate-manifests.sh) before pushing manifest changes.
