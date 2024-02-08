#!/bin/bash

# Start minikube
minikube start

# Download the metric-server resources
wget https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# Apply metric-server
# We know that it will not work under minikube so we will need to fix it
kubectl apply -f components.yaml

# Check if the metrics-server is working
# We expect to get the following error
### >>> Error from server (ServiceUnavailable): the server is currently unable to handle the request (get nodes.metrics.k8s.io)
kubectl top nodes

kubectl get deployment metrics-server -n kube-system
# NAME             READY   UP-TO-DATE   AVAILABLE   AGE
# metrics-server   0/1     1            0           71s

# View the error 
## We should see error like this:
## "Failed to scrape node" err="Get \"https://192.168.49.2:10250/metrics/resource\": 
## x509: cannot validate certificate for 192.168.49.2 because it doesn't contain any IP SANs" node="minikube"
kubectl logs -n kube-system deploy/metrics-server

###
### Fixing the error
###
# We need to fix the tls before we can install the mertric-server

# Get the kubelet configuration
KUBELET_CONFIG=$(kubectl get configmap -n kube-system --no-headers -o custom-columns=":metadata.name" | grep kubelet-config)
kubectl edit configmap $KUBELET_CONFIG -n kube-system

## Add to the following configuration under the `kubelet` ConfigMap
serverTLSBootstrap: true

# We also need to fix the metric server and add the following line under the metric-server Deploymet 

# Edit the deploymnet and add the required lines under the spec
###
### vi components.yaml (~line 140)
###
### spec:
###     containers: 
###     - args
- --kubelet-insecure-tls

# Stop and start minikube
minikube stop && minikube start    

# Uninstall and re-install the metrics-server
kubectl delete -f components.yaml
kubectl apply -f components.yaml

# Verify that now the metric server is working
kubectl top nodes
kubectl top pods -A