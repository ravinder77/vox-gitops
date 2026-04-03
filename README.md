# vox-gitops

GitOps repo for the Vox platform on EKS.

## Structure

- `argocd/bootstrap/`: bootstrap objects that let Argo manage this repo itself
- `argocd/apps/`: top-level parent applications for the core, platform, and workload layers
- `helm/`: workload Helm charts
- `platform/`: shared infrastructure manifests applied through Argo
- `scripts/`: helper scripts

## Deployment Flow

1. Apply the root application from `argocd/bootstrap/root-app.yaml`.
2. The root application syncs `argocd/apps/`.
3. `argocd/apps/core.yaml` installs the `vox` project and shared controllers such as monitoring, rollouts, external-secrets, image-updater, and the AWS load balancer controller.
4. `argocd/apps/platform.yaml` deploys shared platform resources such as the Gateway API configuration and the external-secrets `ClusterSecretStore`.
5. `argocd/apps/workloads.yaml` deploys the frontend and backend charts from `helm/`.

## Architecture

- `core`: cluster-wide operators and Argo CD project policy
- `platform`: shared networking and security primitives used by workloads
- `workloads`: application delivery only

This keeps the GitOps control flow simple: bootstrap Argo once, then let parent apps fan out by responsibility instead of mixing controllers, infrastructure, and workloads in a single folder.
