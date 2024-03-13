#!/bin/bash

# Select all yaml files, except the Helmsman related ones. These are
# detected by exluding files with filenames starting with "helmfile." or "values-".
KUBERNETES_RESOURCE_FILES=$(find * -type f \( -iname '*.yml' -or -iname '*.yaml' \) -and ! \( -iname "helmfile.yaml" -or -iname "values-*.yaml" -or -iname "*docker-compose*" \))

excludes=(
  kubernetes-exercises/deployments-ingress/start/frontend-deployment.yaml
  kubernetes-exercises/deployments-ingress/start/backend-deployment.yaml
  kubernetes-exercises/manifests/start/frontend-pod.yaml
  kubernetes-exercises/services/start/backend-svc.yaml
  kubernetes-exercises/services/start/frontend-svc.yaml
  kubernetes-exercises/kubernetes-exercises/old/support-files/traefik-rbac-serviceaccount.yaml
  kubernetes-exercises/old/ingress-nginx/ingress.yml
  kubernetes-exercises/old/support-files/traefik-service.yaml
  kubernetes-exercises/old/extras/08-ingress-gke.md.yaml
  kubernetes-exercises/old/extras/08-ingress-gke.md.yaml
  kubernetes-exercises/old/extras/08-ingress-traefik.md.yaml
  kubernetes-exercises/old/support-files/traefik-rbac-serviceaccount.yaml
  kubernetes-exercises/old/extras/08-ingress-traefik.md.yaml
  kubernetes-exercises/old/extras/08-ingress-traefik.md.yaml
  kubernetes-exercises/old/extras/08-ingress-traefik.md.yaml
  kubernetes-exercises/old/ingress-gke/ingress.yml
  kubernetes-exercises/old/ingress-traefik/traefik-rbac.yaml
  kubernetes-exercises/old/ingress-traefik/traefik-rbac.yaml
  kubernetes-exercises/old/ingress-traefik/traefik-webui-ingress.yaml
  kubernetes-exercises/old/ingress-traefik/example-ingress.yaml
  kubernetes-exercises/old/ingress-traefik/my-ingress.yml
  kubernetes-exercises/old/ingress-traefik/traefik-ingress-controller.yml
)
for exclude in ${excludes[@]}
do
   KUBERNETES_RESOURCE_FILES=("${KUBERNETES_RESOURCE_FILES[@]/$exclude}")
done

# Run all files through kubeconform
docker run --rm -v ${PWD}:/fixtures -w /fixtures ghcr.io/yannh/kubeconform -summary $KUBERNETES_RESOURCE_FILES
