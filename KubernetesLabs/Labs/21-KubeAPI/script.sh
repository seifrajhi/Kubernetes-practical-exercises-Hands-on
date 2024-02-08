#!/bin/bash -x

# Build 
docker build -t nirgeier/monitor-app .

# push image to docker hub
docker push nirgeier/monitor-app

# Deploy the pod to the cluster
kubectl kustomize k8s | kubectl delete -f -
kubectl kustomize k8s | kubectl apply -f -

# Get the deployment pod name
POD_NAME=$(kubectl get pod -A -l app=monitor-app -o jsonpath="{.items[0].metadata.name}")

# Print out the logs to verify that the pods is conneted to the API
kubectl exec -it -n codewizard $POD_NAME sh ./api_query.sh