#!/bin/bash 

set -x 
### Use this (( for tee the output to a file))
((

### Variables
RANCHER_HOST=rancher.k3d.localhost 
CLUSTER_NAME=rancher-cluster
CERT_MANAGER_RELEASE=v1.8.0
API_PORT=6555
SSL_PORT=6443

### Clear prevoius content
# docker  stop    $(docker ps -aq)
# docker  rm      $(docker ps -aq)

### Remove all docker leftovers (containers, network etc)
docker system prune -f

kubectl delete namespace cattle-system
kubectl delete namespace cert-manager

### Remove old cluster in case there are some leftovers
k3d     cluster \
        delete  \
        $CLUSTER_NAME

### Create a k3d cluster. Use the loadbalancer provided by k3d
k3d     cluster             \
        create              \
        --wait              \
        $CLUSTER_NAME       \
        --servers   1       \
        --agents    3       \
        --api-port  $API_PORT    \
        --kubeconfig-switch-context         \
        --port      $SSL_PORT:443@loadbalancer    
        # --k3s-arg "--disable=traefik@server:*" \
        # --k3s-arg '--kubelet-arg=eviction-hard=imagefs.available<1%,nodefs.available<1%@agent:*' \
        # --k3s-arg '--kubelet-arg=eviction-minimum-reclaim=imagefs.available=1%,nodefs.available=1%@agent:*' \
        # --k3s-arg '--kube-apiserver-arg=feature-gates=EphemeralContainers=false@server:*' 

### Verify the installation
kubectl cluster-info
k3d cluster list

### Add the k3s to the kubeconfig 
k3d     kubeconfig merge    \
        $CLUSTER_NAME       \
        --kubeconfig-switch-context

### Create the namespace(s) for Rancher & cert-manager
#kubectl create namespace cattle-system
#kubectl create namespace cert-manager

### Install Cert-manager
helm    install                         \
        --wait                          \
        --create-namespace              \
        --set installCRDs=true          \
        --namespace cert-manager        \
        --set prometheus.enabled=true   \
        --version $CERT_MANAGER_RELEASE \
        cert-manager jetstack/cert-manager       
        
### Verify cert-manager installation
kubectl rollout             \
        status              \
        deploy/cert-manager \
        --namespace cert-manager
        
### Install racnher
helm    install                     \
        --wait                      \
        --create-namespace          \
        rancher rancher/rancher     \
        --namespace cattle-system   \
        --set hostname=$RANCHER_HOST  

### Verify rancher installation
kubectl rollout status  \
        deploy/racnher  \
        -n cattle-system
        
### Check that the cert-manager API is ready
### We expect to see the foloowing message: 'The cert-manager API is ready'
cmctl check api

### Open broswer in: https://rancher.k3d.localhost
######
###### Important, once on this page type; thisisunsafe
######

### Get the rancher password
kubectl get secret --namespace cattle-system bootstrap-secret -o go-template='{{.data.bootstrapPassword|base64decode}}{{"\n"}}'

### Verify the cluster nodes
kubectl get nodes

### Get the pods status in the background
kubectl get pods -A --watch &

) 2>&1 ) | tee install.txt
