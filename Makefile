# vox-gitops Makefile
# Usage: make <target>
# Requires: kubectl, helm, argocd CLI, aws CLI

CLUSTER_NAME   ?= vox-eks-cluster
REGION         ?= ap-south-1
ARGOCD_VERSION ?= v2.10.0
NAMESPACE      ?= argocd

.PHONY: help bootstrap argocd-install argocd-login sync-waves rollout-status port-forward clean

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
	  awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-25s\033[0m %s\n", $$1, $$2}'

## ── Step 1: Update kubeconfig ───────────────────────────────────────────────
kubeconfig: ## Update kubeconfig for EKS cluster
	aws eks update-kubeconfig --name $(CLUSTER_NAME) --region $(REGION)

## ── Step 2: Install ArgoCD ──────────────────────────────────────────────────
argocd-install: ## Install ArgoCD into the cluster
	kubectl create namespace $(NAMESPACE) --dry-run=client -o yaml | kubectl apply -f -
	kubectl apply -n $(NAMESPACE) \
	  -f https://raw.githubusercontent.com/argoproj/argo-cd/$(ARGOCD_VERSION)/manifests/install.yaml
	kubectl wait --for=condition=available --timeout=120s \
	  deployment/argocd-server -n $(NAMESPACE)
	@echo "✅ ArgoCD installed"

## ── Step 3: Bootstrap the platform ─────────────────────────────────────────
bootstrap: ## Apply AppProject + root App of Apps (one-time only)
	kubectl apply -f argocd/project/vox-project.yaml
	kubectl apply -f argocd/bootstrap/root-app.yaml
	@echo "✅ Bootstrap complete — ArgoCD will reconcile everything from here"

## ── ArgoCD CLI login ────────────────────────────────────────────────────────
argocd-login: ## Port-forward ArgoCD and login via CLI
	@PASS=$$(kubectl -n $(NAMESPACE) get secret argocd-initial-admin-secret \
	  -o jsonpath="{.data.password}" | base64 -d); \
	kubectl port-forward svc/argocd-server -n $(NAMESPACE) 8080:443 & \
	sleep 2 && \
	argocd login localhost:8080 --username admin --password $$PASS --insecure && \
	echo "✅ Logged in as admin"

## ── Sync wave status ────────────────────────────────────────────────────────
sync-status: ## Show all ArgoCD application sync statuses
	argocd app list -o wide

## ── Rollout status ──────────────────────────────────────────────────────────
rollout-status: ## Show Argo Rollouts status for backend and frontend
	kubectl argo rollouts get rollout vox-backend -n vox-backend --watch &
	kubectl argo rollouts get rollout vox-frontend -n vox-frontend --watch

## ── Promote canary ──────────────────────────────────────────────────────────
promote-backend: ## Manually promote backend canary to stable
	kubectl argo rollouts promote vox-backend -n vox-backend

abort-backend: ## Abort backend canary and rollback
	kubectl argo rollouts abort vox-backend -n vox-backend

## ── Port-forward Prometheus/Grafana ─────────────────────────────────────────
port-forward-grafana: ## Port-forward Grafana to localhost:3000
	kubectl port-forward svc/kube-prometheus-stack-grafana -n monitoring 3000:80

port-forward-prometheus: ## Port-forward Prometheus to localhost:9090
	kubectl port-forward svc/kube-prometheus-stack-prometheus -n monitoring 9090:9090

port-forward-rollouts: ## Port-forward Argo Rollouts dashboard to localhost:3100
	kubectl argo rollouts dashboard -n vox-backend

## ── Secrets debugging ────────────────────────────────────────────────────────
check-secrets: ## Check ExternalSecret sync status
	kubectl get externalsecret -A
	kubectl get clustersecretstore

## ── Tear down ────────────────────────────────────────────────────────────────
clean: ## Delete all ArgoCD apps (use with caution)
	argocd app delete vox-root --cascade