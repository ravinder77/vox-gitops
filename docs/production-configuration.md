# Production Configuration

The repo now treats unresolved placeholders as a validation failure. Before deploying to EKS, replace every production placeholder in deployable manifests.

## Required Values

- `AWS_ACCOUNT_ID`
  Used in:
  `argocd/apps/backend.yaml`
  `argocd/apps/frontend.yaml`
  `argocd/apps/image-updater.yaml`
  `helm/backend/values.yaml`
  `helm/frontend/values.yaml`
  `helm/external-secrets/values.yaml`
  `platform/security/irsa/*.yaml`
  `platform/policies/admission/verify-image-signature.yaml`

- Slack webhook URL
  Used in:
  `helm/monitoring/values.yaml`

- Public DNS names
  Used in:
  `platform/gateway/tg-frontend.yaml`
  `platform/gateway/tg-backend.yaml`

- ACM certificate ARN
  Used in:
  `platform/gateway/gateway.yaml`

## Validation

Run:

```bash
bash scripts/validate-manifests.sh
```

Validation fails until all deploy-time placeholders are replaced.
