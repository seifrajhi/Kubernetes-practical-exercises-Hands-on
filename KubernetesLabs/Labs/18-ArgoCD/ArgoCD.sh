# Define the desired namespace
NAMESPACE=argocd

# start the minikube cluster
# minikube start

# Download ArgoCD CLI
VERSION=$(curl --silent "https://api.github.com/repos/argoproj/argo-cd/releases/latest" | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')
sudo curl -sSL -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/download/$VERSION/argocd-linux-amd64
sudo chmod +x /usr/local/bin/argocd

# Deploy ArgoCD - create namespace
kubectl create namespace $NAMESPACE

# Set the default namesapce
kubectl config set-context --current --namespace=$NAMESPACE

# Change the argocd-server service type to LoadBalancer:
#kubectl patch svc argocd-server -n $NAMESPACE -p '{"spec": {"type": "NodePort"}}'

# Set the new desired Deployment
cat << EOF > kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namespace: argocd
resources:
  - https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
  
patchesStrategicMerge:
- patch-replace.yaml  
EOF

# Set the desired patch
cat << EOF > patch-replace.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: argocd-server
spec:
  selector:
    matchLabels:
      app.kubernetes.io/name: argocd-server
  template:
    spec:
      containers:
      - name: argocd-server
        command:
        - argocd-server
        - --insecure
        - --staticassets
        - /shared/app
EOF

kubectl kustomize . | kubectl apply -f -
sleep 30

echo '---------------------------------------------------------------'
echo 'User    : admin'
echo 'Password: ' $(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
echo '---------------------------------------------------------------'


kubectl port-forward svc/argocd-server -n argocd 8085:80
