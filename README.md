# vox-gitops

GitOps repo for the Vox platform on EKS.

## Structure

- `argocd/bootstrap/`: bootstrap objects that let Argo manage this repo itself
- `argocd/app-of-apps/`: parent applications and the Argo project definition
- `argocd/addons/`: shared cluster services such as monitoring, rollouts, and secrets
- `argocd/platform/`: platform controllers, CRDs, and networking applications
- `argocd/workloads/`: workload `Application` manifests
- `helm/`: workload Helm charts
- `platform/`: shared infrastructure manifests applied through Argo
- `scripts/`: helper scripts

## Deployment Flow

1. Apply the root application from `argocd/bootstrap/root-app.yaml`.
2. The root application syncs `argocd/app-of-apps/`.
3. Parent applications create the `vox` project and fan out to `addons`, `platform`, and `workloads`.
4. Platform applications install controllers and shared infrastructure.
5. Workload applications deploy the frontend and backend charts from `helm/`.
