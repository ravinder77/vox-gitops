#!/usr/bin/env bash

set -euo pipefail

kubectl delete -f argocd/bootstrap/root-app.yaml --ignore-not-found
kubectl delete -f argocd/project/vox-project.yaml --ignore-not-found
