# vox-gitops

GitOps repo for the Vox platform on EKS.

## Structure

- `argocd/bootstrap/`: bootstrap objects that let Argo manage this repo itself
- `argocd/apps/core/`: shared controllers and cluster services
- `argocd/apps/platform/`: platform networking and Gateway API controller applications
- `argocd/apps/workloads/`: workload `Application` manifests
- `helm/`: workload Helm charts
- `platform/`: shared infrastructure manifests applied through Argo
- `scripts/`: helper scripts

## Deployment Flow

1. Apply the root application from `argocd/bootstrap/root-app.yaml`.
2. Argo syncs the project definition and all applications under `argocd/`.
3. Core and platform applications install controllers and cluster prerequisites.
4. Workload applications deploy the frontend and backend charts from `helm/`.
