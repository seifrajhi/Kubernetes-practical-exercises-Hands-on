#!/bin/sh

# output the commands to the terminal 
set -x

# Create Namespace
kubectl create namespace prometheus

# Add the prometheus helm repo if its not already exist
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

# update helm repo
helm repo update

# Install prometheus / grafana
helm install prometheus prometheus-community/kube-prometheus-stack --namespace prometheus

# Wait for the pods to start
kubectl get pods -n prometheus

# Port forwarding prometheus & grafana
kubectl port-forward -n prometheus prometheus-prometheus-kube-prometheus-prometheus-0 9090

# Get the grafana pod name
# Get the pod name
kubectl port-forward -n prometheus \
  $(kubectl get pods --selector=app.kubernetes.io/name=grafana -n prometheus -o jsonpath='{.items[*].metadata.name}') \
  3000

# Get the grafana username /password
#     admin-user:       YWRtaW4=                => admin
#     admin-password:   cHJvbS1vcGVyYXRvcg==    => prom-operator
kubectl get secret --namespace prometheus prometheus-grafana -o yaml

# Open your browser on ports 
#   3000 - Grafana
#   9090 - Prometheus
